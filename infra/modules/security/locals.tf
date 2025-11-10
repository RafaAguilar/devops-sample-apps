data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "random_string" "this" {
  for_each = toset(var.applications)

  length  = 4
  special = false
  upper   = false
}