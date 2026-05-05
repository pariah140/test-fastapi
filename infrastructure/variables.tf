# App Runner Variables

variable "name" {
  description = "Application name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

variable "container_image" {
  description = "Container image to deploy (set by GitHub Actions)"
  type        = string
  default     = ""
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 8000
}

variable "task_cpu" {
  description = "CPU units for App Runner (256, 512, 1024, 2048, 4096)"
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "Memory in MB for App Runner (512, 1024, 2048, 3072, 4096, 6144, 8192, 10240, 12288)"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Desired number of instances (informational for App Runner which uses min/max)"
  type        = number
  default     = 1
}

variable "min_capacity" {
  description = "Minimum number of instances (App Runner minimum is 1)"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of instances"
  type        = number
  default     = 3
}

variable "max_concurrency" {
  description = "Maximum concurrent requests per instance before scaling"
  type        = number
  default     = 100
}

variable "health_check_path" {
  description = "Health check endpoint path"
  type        = string
  default     = "/health"
}

variable "enable_workers" {
  description = "Enable background worker processes"
  type        = bool
  default     = false
}

variable "environment_variables" {
  description = "Environment variables for the application"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "use_ecr_image" {
  description = "Whether to use ECR image (false for initial bootstrap with public hello-app-runner image)"
  type        = bool
  default     = false
}
