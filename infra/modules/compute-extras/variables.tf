variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_autoscaler_chart_version" {
  description = "Version of the Cluster Autoscaler Chart Version"
  type        = string
  default     = "9.52.1"
}