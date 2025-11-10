# required
variable "env" {
  description = "Environment"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EFS mount targets"
  type        = list(string)
}

variable "cluster_security_group_id" {
  description = "Security group ID of the EKS cluster"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for the EKS cluster"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the OIDC provider for the EKS cluster"
  type        = string
}

# defaults
variable "efs_performance_mode" {
  description = "Performance mode for the EFS file system"
  type        = string
  default     = "generalPurpose"
}

variable "efs_throughput_mode" {
  description = "Throughput mode for the EFS file system"
  type        = string
  default     = "bursting"
}

variable "efs_encrypted" {
  description = "Whether to encrypt the EFS file system"
  type        = bool
  default     = true
}

variable "efs_csi_driver_role_name" {
  description = "Name of the IAM role for the EFS CSI driver"
  type        = string
  default     = null
}

variable "efs_csi_service_account_name" {
  description = "Name of the EFS CSI driver service account"
  type        = string
  default     = "efs-csi-controller-sa"
}

variable "efs_csi_driver_version" {
  description = "Version of the EFS CSI driver Helm chart"
  type        = string
  default     = "3.0.3"
}

variable "efs_csi_driver_repository" {
  description = "Helm repository URL for the EFS CSI driver"
  type        = string
  default     = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
}

variable "efs_csi_driver_namespace" {
  description = "Kubernetes namespace for the EFS CSI driver"
  type        = string
  default     = "kube-system"
}

variable "efs_storage_class_name" {
  description = "Name of the Kubernetes storage class for EFS"
  type        = string
  default     = "efs"
}

variable "efs_directory_perms" {
  description = "Directory permissions for EFS access points"
  type        = string
  default     = "700"
}