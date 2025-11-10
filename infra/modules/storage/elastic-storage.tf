locals {
  efs_csi_role_name = var.efs_csi_driver_role_name != null ? var.efs_csi_driver_role_name : "${var.cluster_name}-efs-csi-driver"
}

resource "aws_efs_file_system" "this" {
  creation_token = "${var.env}-${data.aws_region.current.id}-eks"

  performance_mode = var.efs_performance_mode
  throughput_mode  = var.efs_throughput_mode
  encrypted        = var.efs_encrypted
}

resource "aws_efs_mount_target" "this" {
  for_each = toset(var.private_subnet_ids)

  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.value
  security_groups = var.cluster_security_group_id
}

data "aws_iam_policy_document" "efs_csi_driver" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.efs_csi_driver_namespace}:${var.efs_csi_service_account_name}"]
    }

    principals {
      identifiers = [var.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "efs_csi_driver" {
  name               = local.efs_csi_role_name
  assume_role_policy = data.aws_iam_policy_document.efs_csi_driver.json
}

resource "aws_iam_role_policy_attachment" "efs_csi_driver" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role       = aws_iam_role.efs_csi_driver.name
}

resource "helm_release" "efs_csi_driver" {
  name = "aws-efs-csi-driver"

  repository = var.efs_csi_driver_repository
  chart      = "aws-efs-csi-driver"
  namespace  = var.efs_csi_driver_namespace
  version    = var.efs_csi_driver_version

  set {
    name  = "controller.serviceAccount.name"
    value = var.efs_csi_service_account_name
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.efs_csi_driver.arn
  }

  depends_on = [aws_efs_mount_target.this]
}

resource "kubernetes_storage_class_v1" "this" {
  metadata {
    name = var.efs_storage_class_name
  }

  storage_provisioner = "efs.csi.aws.com"

  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.this.id
    directoryPerms   = var.efs_directory_perms
  }

  mount_options = ["iam"]

  depends_on = [helm_release.efs_csi_driver]
}