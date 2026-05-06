/**
 * CDN Static Module - Variables
 */

variable "name" {
  description = "Application name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "domain_aliases" {
  description = "List of custom domain aliases for CloudFront"
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for custom domains (must be in us-east-1)"
  type        = string
  default     = null
}

variable "default_root_object" {
  description = "Default root object for CloudFront"
  type        = string
  default     = "index.html"
}

variable "price_class" {
  description = "CloudFront price class (PriceClass_All, PriceClass_200, PriceClass_100)"
  type        = string
  default     = "PriceClass_100"
}

variable "default_ttl" {
  description = "Default TTL for objects (seconds)"
  type        = number
  default     = 86400 # 1 day
}

variable "max_ttl" {
  description = "Maximum TTL for objects (seconds)"
  type        = number
  default     = 31536000 # 1 year
}

variable "enable_nextjs_optimization" {
  description = "Enable Next.js specific cache behaviors"
  type        = bool
  default     = true
}

variable "geo_restriction_type" {
  description = "Geo restriction type (none, whitelist, blacklist)"
  type        = string
  default     = "none"
}

variable "geo_restriction_locations" {
  description = "List of country codes for geo restriction"
  type        = list(string)
  default     = []
}

variable "enable_logging" {
  description = "Enable CloudFront access logging"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
