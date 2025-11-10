resource "random_string" "this" {
  for_each = toset(var.applications)

  length  = 4
  special = false
  upper   = false
}

resource "random_password" "this" {
  for_each = toset(var.applications)

  length  = 20
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each = toset(var.applications)

  secret_id = var.aws_main_secret_id[each.value]

  secret_string = jsonencode({
    db_name     = aws_db_instance.main[each.value].db_name
    db_username = aws_db_instance.main[each.value].username
    db_password = random_password.this[each.value].result
    db_url      = aws_db_instance.main[each.value].address
  })
}