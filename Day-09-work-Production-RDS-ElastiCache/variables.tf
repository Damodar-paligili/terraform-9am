variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Name used for resource naming."
  type        = string
  default     = "prod-data"
}

variable "environment" {
  description = "Environment name used in tags and resource names."
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs. Use at least two subnets in different AZs."
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "Provide at least two private subnet CIDRs for multi-AZ RDS and ElastiCache."
  }
}

variable "app_ingress_cidr_blocks" {
  description = "Optional CIDRs allowed to reach the application security group. Keep empty when attaching compute security groups yourself."
  type        = list(string)
  default     = []
}

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "RDS master username. Password is managed by AWS Secrets Manager."
  type        = string
  default     = "adminuser"
  sensitive   = true
}

variable "db_instance_class" {
  description = "Primary RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_replica_instance_class" {
  description = "Read replica RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage_gb" {
  description = "Initial allocated RDS storage in GB."
  type        = number
  default     = 20
}

variable "db_max_allocated_storage_gb" {
  description = "Maximum RDS autoscaled storage in GB."
  type        = number
  default     = 500
}

variable "db_engine_version" {
  description = "MySQL engine version."
  type        = string
  default     = "8.0"
}

variable "db_backup_retention_days" {
  description = "Number of days to retain automated RDS backups."
  type        = number
  default     = 1
}

variable "deletion_protection" {
  description = "Enable deletion protection for production resources."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Set true only for non-production teardown."
  type        = bool
  default     = true
}

variable "redis_node_type" {
  description = "ElastiCache Redis node type."
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_replicas_per_node_group" {
  description = "Number of Redis read replicas in the node group."
  type        = number
  default     = 1
}

variable "redis_engine_version" {
  description = "Redis engine version for ElastiCache."
  type        = string
  default     = "7.1"
}

variable "redis_snapshot_retention_days" {
  description = "Number of days to retain Redis snapshots."
  type        = number
  default     = 1
}

