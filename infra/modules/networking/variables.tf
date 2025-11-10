variable "env" {
  description = "Environment"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr_block, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block"
  }

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.vpc_cidr_block))
    error_message = "VPC CIDR must be in valid CIDR notation (e.g., 10.0.0.0/16)"
  }
}

variable "redundancy" {
  description = "Redundancy level for subnet pairs"
  type        = string
  default     = "single"

  validation {
    condition     = contains(["single", "failover", "robust"], var.redundancy)
    error_message = "Redundancy must be one of: single, failover, robust"
  }
}

variable "private_subnet_tags" {
  description = "Private subnet tags"
  type        = map(any)
}

variable "public_subnet_tags" {
  description = "Private subnet tags"
  type        = map(any)
}