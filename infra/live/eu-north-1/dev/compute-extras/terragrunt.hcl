terraform {
  source = "../../../../modules/compute-extras"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  cluster_name = dependency.compute.outputs.eks_name
}

dependency "compute" {
  config_path = "../compute"

  mock_outputs = {
    eks_name = "cluster"

    eks_cluster_endpoint              = "http://127.0.0.1:9999"
    eks_cluster_certificate_authority = [{ "data" : "aGVsbG8gZG9jdG9yYWxpYSB0ZWFtLCBuaWNlIGZpbmRpbmcgdGhpcyBlYXN0ZXIgZWdnIDsp" }]
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

