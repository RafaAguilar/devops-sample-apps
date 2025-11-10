variable "env" {
  description = "Environment"
  type        = string
}


variable "aws_eks_cluster_eks_name" {
  description = "aws_eks_cluster_eks_name"
  type        = string
}


variable "vpc_id" {
  description = "AWS Target VPC id"
  type        = string
}

variable "aws_lb_controller_helm_verion" {
  description = "AWS Load Balancer Controller Helm verion"
  type        = string
}

variable "nginx_ingress_helm_verion" {
  description = "Nginx Ingress Helm verion"
  type        = string
}