variable "name" {
  description = "Application name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "container_image" {
  description = "Docker image URL"
  type        = string
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 8000
}

variable "cpu" {
  description = "Fargate CPU units"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Fargate memory in MB"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 2
}

variable "min_count" {
  description = "Minimum number of tasks"
  type        = number
  default     = 1
}

variable "max_count" {
  description = "Maximum number of tasks"
  type        = number
  default     = 10
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
}

variable "enable_waf" {
  description = "Enable WAF on ALB"
  type        = bool
  default     = true
}

variable "encryption_enabled" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

variable "use_secrets_manager" {
  description = "Use Secrets Manager for sensitive variables"
  type        = bool
  default     = true
}

variable "secrets" {
  description = "Map of secret names to Secrets Manager ARNs"
  type        = map(string)
  default     = {}
}

variable "environment_variables" {
  description = "Environment variables for container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/health"
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Healthy threshold count"
  type        = number
  default     = 3
}

variable "health_check_unhealthy_threshold" {
  description = "Unhealthy threshold count"
  type        = number
  default     = 2
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

# WAF Rate Limiting
variable "waf_auth_rate_limit" {
  description = "Rate limit for auth endpoints (requests per 5 minutes per IP)"
  type        = number
  default     = 100  # 100 requests per 5 minutes = ~20/min
}

variable "waf_general_rate_limit" {
  description = "Rate limit for all endpoints (requests per 5 minutes per IP)"
  type        = number
  default     = 2000  # 2000 requests per 5 minutes = ~400/min
}
