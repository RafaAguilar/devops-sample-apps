resource "helm_release" "secrets_csi_driver" {
  name = "secrets-store-csi-driver"

  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  namespace  = "kube-system"
  version    = var.secretes_csi_driver_version

  set {
    name  = "syncSecret.enabled"
    value = true
  }
}

resource "helm_release" "secrets_csi_driver_aws_provider" {
  name = "secrets-store-csi-driver-provider-aws"

  repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  chart      = "secrets-store-csi-driver-provider-aws"
  namespace  = "kube-system"
  version    = var.secretes_csi_provider_version

  depends_on = [helm_release.secrets_csi_driver]
}

data "aws_iam_policy_document" "secrets_csi_provider" {
  for_each = toset(var.applications)

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:devops-demo:${each.value}-service-account"]
    }

    principals {
      identifiers = [var.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "secrets_csi_provider" {
  for_each = toset(var.applications)

  name               = "${var.env}-${data.aws_region.current.id}-${each.value}-secrets"
  assume_role_policy = data.aws_iam_policy_document.secrets_csi_provider[each.value].json
}

resource "aws_iam_policy" "secrets_csi_provider" {
  for_each = toset(var.applications)

  name = "${var.env}-${data.aws_region.current.id}-${each.value}-secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:secret:${var.env}/${each.value}-*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_csi_provider" {
  for_each = toset(var.applications)

  policy_arn = aws_iam_policy.secrets_csi_provider[each.value].arn
  role       = aws_iam_role.secrets_csi_provider[each.value].name
}


resource "aws_secretsmanager_secret" "this" {
  for_each = toset(var.applications)

  name        = "${var.env}/${each.value}-secret-${random_string.this[each.value].result}"
  description = "Main secret for app ${each.value} on ${var.env} environment."

  #tags # TODO:

}