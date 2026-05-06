/**
 * RDS PostgreSQL Module - Variables
 */

variable "name" {
  description = "Application name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for DB subnet group"
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "List of security group IDs allowed to access the database"
  type        = list(string)
  default     = []
}

# Database configuration
variable "database_name" {
  description = "Name of the database to create"
  type        = string
  default     = "app"
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
  default     = "postgres"
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "15.4"
}

# Instance configuration
variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage for autoscaling (0 to disable)"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type (gp2, gp3, io1)"
  type        = string
  default     = "gp3"
}

# High availability
variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = true
}

variable "availability_zone" {
  description = "Availability zone (only used if multi_az is false)"
  type        = string
  default     = null
}

# Network
variable "publicly_accessible" {
  description = "Whether the DB instance is publicly accessible"
  type        = bool
  default     = false
}

# Backups
variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Preferred backup window (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Preferred maintenance window (UTC)"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "delete_automated_backups" {
  description = "Delete automated backups after instance deletion"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = false
}

# Performance Insights
variable "enable_performance_insights" {
  description = "Enable Performance Insights"
  type        = bool
  default     = true
}

variable "performance_insights_retention" {
  description = "Performance Insights retention period in days"
  type        = number
  default     = 7
}

# Monitoring
variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds (0, 1, 5, 10, 15, 30, 60)"
  type        = number
  default     = 60
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch (postgresql, upgrade)"
  type        = list(string)
  default     = ["postgresql", "upgrade"]
}

variable "cloudwatch_logs_retention" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 7
}

# Parameters
variable "parameter_group_family" {
  description = "DB parameter group family"
  type        = string
  default     = "postgres15"
}

variable "parameters" {
  description = "List of DB parameters to apply"
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = [
    {
      name  = "log_statement"
      value = "all"
    },
    {
      name  = "log_min_duration_statement"
      value = "1000" # Log queries slower than 1s
    },
    {
      name  = "log_connections"
      value = "1"
    },
    {
      name  = "log_disconnections"
      value = "1"
    },
    {
      name  = "shared_preload_libraries"
      value = "pg_stat_statements"
    }
  ]
}

# Upgrades
variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

variable "allow_major_version_upgrade" {
  description = "Allow major version upgrades"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Apply changes immediately (vs during maintenance window)"
  type        = bool
  default     = false
}

# Protection
variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "secret_recovery_days" {
  description = "Secrets Manager recovery window in days"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

# RDS Proxy configuration
variable "enable_rds_proxy" {
  description = "Enable RDS Proxy for connection pooling and IAM auth"
  type        = bool
  default     = false
}

variable "proxy_debug_logging" {
  description = "Enable debug logging for RDS Proxy"
  type        = bool
  default     = false
}

variable "proxy_idle_timeout" {
  description = "Idle client timeout in seconds (1-28800)"
  type        = number
  default     = 1800
}

variable "proxy_iam_auth" {
  description = "Require IAM authentication for RDS Proxy connections"
  type        = bool
  default     = true
}

variable "proxy_connection_borrow_timeout" {
  description = "Connection borrow timeout in seconds"
  type        = number
  default     = 120
}

variable "proxy_max_connections_percent" {
  description = "Maximum percentage of max_connections to use"
  type        = number
  default     = 100
}

variable "proxy_max_idle_connections_percent" {
  description = "Maximum percentage of connections to keep idle"
  type        = number
  default     = 50
}

variable "iam_db_username" {
  description = "Database username for IAM authentication"
  type        = string
  default     = "galleon_app"
}
