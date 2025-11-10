terraform {
  source = "../../../../modules/database"
}

include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path           = find_in_parent_folders("locals.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

inputs = {
  env     = include.env.locals.env
  vpc_id  = dependency.networking.outputs.vpc_id
  subnets = dependency.networking.outputs.private_subnet_ids

  redundancy          = include.env.locals.redundancy
  applications        = ["golang", "php"] # TODO: fix this is tightly coupled with order below =/
  aws_main_secret_id  = dependency.security.outputs.main_secrets
  allowed_cidr_blocks = [dependency.networking.outputs.vpc_cidr_block]
}

dependency "networking" {
  config_path = "../networking"

  mock_outputs = {
    vpc_id             = "vpc-id"
    private_subnet_ids = ["env-subnet-a", "env-subnet-b"]
    vpc_cidr_block     = "10.0.0.0/16"
  }
}

dependency "security" {
  config_path = "../security"

  mock_outputs = {
    main_secrets = {
      "golang" = "golang-secret",
      "php"    = "php-secret"
    }
  }
}
