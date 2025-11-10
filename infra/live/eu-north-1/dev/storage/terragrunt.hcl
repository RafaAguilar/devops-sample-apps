terraform {
  source = "../../../../modules/storage"
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
  env = include.env.locals.env

  # network
  private_subnet_ids = dependency.networking.outputs.private_subnet_ids

  # eks
  cluster_name              = dependency.compute.outputs.eks_name
  cluster_security_group_id = dependency.compute.outputs.eks_cluster_security_group
  oidc_provider_arn         = dependency.compute.outputs.openid_provider_arn
  oidc_provider_url         = dependency.compute.outputs.openid_provider_url

}

dependency "networking" {
  config_path = "../networking"

  mock_outputs = {
    private_subnet_ids = ["env-subnet-a", "env-subnet-b"]
  }
}

dependency "compute" {
  config_path = "../compute"

  mock_outputs = {
    eks_name = "eks-cluster"

    eks_cluster_endpoint              = "http://127.0.0.1:9999"
    eks_cluster_certificate_authority = [{ "data" : "aGVsbG8gZG9jdG9yYWxpYSB0ZWFtLCBuaWNlIGZpbmRpbmcgdGhpcyBlYXN0ZXIgZWdnIDsp" }]
    eks_cluster_security_group        = ["eks_security_group"]

    openid_provider_url = "http://127.0.0.1"
    openid_provider_arn = "arn:1111111:eeeeeeee:22222222"
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

