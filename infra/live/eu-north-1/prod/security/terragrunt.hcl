terraform {
  source = "../../../../modules/security"
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
  env          = include.env.locals.env
  applications = ["php", "golang"]

  oidc_provider_arn = dependency.compute.outputs.openid_provider_arn
  oidc_provider_url = dependency.compute.outputs.openid_provider_url
}

dependency "compute" {
  config_path = "../compute"

  mock_outputs = {
    eks_name = "cluster"

    eks_cluster_endpoint              = "http://127.0.0.1:9999"
    eks_cluster_certificate_authority = [{ "data" : "aGVsbG8gZG9jdG9yYWxpYSB0ZWFtLCBuaWNlIGZpbmRpbmcgdGhpcyBlYXN0ZXIgZWdnIDsp" }]

    openid_provider_url = "http://127.0.0.1"
    openid_provider_arn = "arn:1111111:eeeeeeee:22222222"
  }
}

dependency "storage" {
  config_path = "../storage"

  mock_outputs = {
    dummy = "this output is just to avoid a terragrunt bug"
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