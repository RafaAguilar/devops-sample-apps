variable "env" {
  description = "Environment"
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

variable "secretes_csi_driver_version" {
  description = "Version of the Secrets Store CSI driver Helm chart"
  type        = string
  default     = "1.4.3"
}

variable "secretes_csi_provider_version" {
  description = "Version of the Secrets Store CSI provider Helm chart"
  type        = string
  default     = "0.3.8"
}

variable "applications" {
  description = "Applications names (e.g. php, golang..)"
  type        = list(string)
}