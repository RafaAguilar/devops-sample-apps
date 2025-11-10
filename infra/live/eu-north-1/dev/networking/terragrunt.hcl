terraform {
  source = "../../../../modules/networking"
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
  env            = include.env.locals.env
  redundancy     = include.env.locals.redundancy
  vpc_cidr_block = "10.8.0.0/19"

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"                  = 1
    "kubernetes.io/cluster/dev-eu-north-1-eks-cluster" = "owned"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb"                           = 1
    "kubernetes.io/cluster/dev-eu-north-1-eks-cluster" = "owned"
  }
}