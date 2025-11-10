output "eks_name" {
  value = aws_eks_cluster.this.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "eks_nodes_role_arn" {
  value = aws_iam_role.nodes.arn
}

output "openid_provider_arn" {
  value = aws_iam_openid_connect_provider.this[0].arn
}

output "openid_provider_url" {
  value = aws_iam_openid_connect_provider.this[0].url
}

output "eks_cluster_certificate_authority" {
  value = aws_eks_cluster.this.certificate_authority
}

output "eks_cluster_security_group" {
  value = [aws_eks_cluster.this.vpc_config[0].cluster_security_group_id]
}

