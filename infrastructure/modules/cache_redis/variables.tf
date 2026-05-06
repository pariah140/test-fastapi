/**
 * ElastiCache Redis Module - Variables
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
  description = "List of subnet IDs for Redis subnet group"
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "List of security group IDs allowed to access Redis"
  type        = list(string)
  default     = []
}

# Redis configuration
variable "redis_version" {
  description = "Redis version"
  type        = string
  default     = "7.0"
}

variable "node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t4g.micro"
}

variable "parameter_group_family" {
  description = "ElastiCache parameter group family"
  type        = string
  default     = "redis7"
}

variable "parameters" {
  description = "List of Redis parameters to apply"
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    {
      name  = "maxmemory-policy"
      value = "allkeys-lru"
    },
    {
      name  = "timeout"
      value = "300"
    }
  ]
}

# Cluster mode
variable "cluster_mode_enabled" {
  description = "Enable Redis cluster mode (sharding)"
  type        = bool
  default     = false
}

# Non-cluster mode configuration
variable "num_cache_nodes" {
  description = "Number of cache nodes (non-cluster mode only, min 1)"
  type        = number
  default     = 2
}

# Cluster mode configuration
variable "num_node_groups" {
  description = "Number of node groups (shards) for cluster mode"
  type        = number
  default     = 2
}

variable "replicas_per_node_group" {
  description = "Number of replica nodes per shard (cluster mode only)"
  type        = number
  default     = 1
}

# High availability
variable "multi_az_enabled" {
  description = "Enable Multi-AZ for automatic failover"
  type        = bool
  default     = true
}

# Encryption
variable "transit_encryption_enabled" {
  description = "Enable encryption in transit (TLS)"
  type        = bool
  default     = true
}

# Backups
variable "snapshot_retention_limit" {
  description = "Number of days to retain automatic snapshots (0 to disable)"
  type        = number
  default     = 7
}

variable "snapshot_window" {
  description = "Preferred snapshot window (UTC)"
  type        = string
  default     = "03:00-05:00"
}

variable "maintenance_window" {
  description = "Preferred maintenance window (UTC)"
  type        = string
  default     = "sun:05:00-sun:07:00"
}

variable "create_final_snapshot" {
  description = "Create final snapshot on deletion"
  type        = bool
  default     = true
}

# Monitoring
variable "notification_topic_arn" {
  description = "SNS topic ARN for ElastiCache notifications"
  type        = string
  default     = null
}

variable "cloudwatch_logs_retention" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 7
}

# Upgrades
variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Apply changes immediately (vs during maintenance window)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
