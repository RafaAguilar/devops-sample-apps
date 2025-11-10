output "secrets_roles_arn" {
  value = {
    for idx, app in var.applications :
    app => aws_iam_role.secrets_csi_provider[app].arn
  }
}

output "main_secrets" {
  value = {
    for idx, app in var.applications :
    app => aws_secretsmanager_secret.this[app].name
  }
}