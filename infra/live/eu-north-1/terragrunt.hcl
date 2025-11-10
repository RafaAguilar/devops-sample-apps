locals {
  aws_region  = "eu-north-1"
  aws_profile = "doctoralia"
}

terraform {
  source = "."
}


remote_state {
  backend = "s3"
  generate = {
    path      = "state.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    profile = local.aws_profile
    #role_arn       = "" # TODO
    bucket = "terraform-state-dev-eu-north-1-019496914213"
    key    = "${path_relative_to_include()}/terraform.tfstate"
    region = local.aws_region

    encrypt        = true
    dynamodb_table = "terraform-lock-dev-eu-north-1"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF
provider "aws" {
  region  = "${local.aws_region}"
  profile = "${local.aws_profile}"

    #assume_role{...} # TODO
}
EOF
}
