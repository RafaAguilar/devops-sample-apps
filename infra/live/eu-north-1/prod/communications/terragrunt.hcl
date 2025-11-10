terraform {
  source = "../../../../modules/communications"
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
  env    = include.env.locals.env
  vpc_id = dependency.networking.outputs.vpc_id

  aws_eks_cluster_eks_name      = dependency.compute.outputs.eks_name
  aws_lb_controller_helm_verion = "1.14.1"
  nginx_ingress_helm_verion     = "4.14.0"
}

dependency "compute" {
  config_path = "../compute"

  mock_outputs = {
    eks_name                          = "eks-cluster"
    eks_cluster_endpoint              = "http://127.0.0.1:9999"
    eks_cluster_certificate_authority = [{ "data" : "aGVsbG8gZG9jdG9yYWxpYSB0ZWFtLCBuaWNlIGZpbmRpbmcgdGhpcyBlYXN0ZXIgZWdnIDsp" }]
  }
}

dependency "networking" {
  config_path = "../networking"

  mock_outputs = {
    vpc_id = "vpc-07e65f96156859249"
  }
}

generate "helm_provider" {
  path      = "helm_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
data "aws_eks_cluster_auth" "eks" {
  name = "${dependency.compute.outputs.eks_name}"
}

provider "helm" {
  kubernetes {
    host                   = "${dependency.compute.outputs.eks_cluster_endpoint}"
    cluster_ca_certificate = base64decode("${dependency.compute.outputs.eks_cluster_certificate_authority[0].data}")
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

provider "kubernetes" {
  host                   = "${dependency.compute.outputs.eks_cluster_endpoint}"
  cluster_ca_certificate = base64decode("${dependency.compute.outputs.eks_cluster_certificate_authority[0].data}")
  token                  = data.aws_eks_cluster_auth.eks.token
}
EOF
}

