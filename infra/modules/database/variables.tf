variable "env" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
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

variable "applications" {
  description = "Application name"
  type        = list(string)
}

variable "subnets" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "aws_main_secret_id" {
  description = "The main secret ID for the app in target Environment"
  type        = map(any)
}

variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
  default     = 20
}

variable "snapshot_retention_days" {
  description = "Number of days to retain automated snapshots"
  type        = number
  default     = 7
}

variable "engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "17.6"
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to the database"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "multi_az" {
  description = "Enable Multi-AZ for high availability"
  type        = bool
  default     = false
}

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}