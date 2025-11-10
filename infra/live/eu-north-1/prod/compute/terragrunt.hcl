terraform {
  source = "../../../../modules/compute"
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
  eks_version = "1.34"
  env         = include.env.locals.env
  eks_name    = "demo"

  subnet_ids         = dependency.networking.outputs.private_subnet_ids
  availability_zones = dependency.networking.outputs.availability_zones

  node_groups = {
    general = {
      capacity_type  = "SPOT"       # TODO: this should be Reserved or OnDemand due to redundancy, not doing it because costs
      instance_types = ["t3.small"] # TODO: validate instance is available at region or make it friendly
      scaling_config = {
        desired_size = 1
        max_size     = 12
        min_size     = 0
      }
    }
  }
}

dependency "networking" {
  config_path = "../networking"

  mock_outputs = {
    private_subnet_ids = ["env-subnet-a", "env-subnet-b"]
    availability_zones = ["eu-north-1a", "eu-north-1b"]
  }
}