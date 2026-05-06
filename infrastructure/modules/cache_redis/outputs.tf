/**
 * ElastiCache Redis Module - Outputs
 */

output "replication_group_id" {
  description = "Redis replication group ID"
  value       = var.cluster_mode_enabled ? aws_elasticache_replication_group.cluster[0].id : aws_elasticache_replication_group.main[0].id
}

output "replication_group_arn" {
  description = "Redis replication group ARN"
  value       = var.cluster_mode_enabled ? aws_elasticache_replication_group.cluster[0].arn : aws_elasticache_replication_group.main[0].arn
}

output "primary_endpoint_address" {
  description = "Primary endpoint address"
  value       = var.cluster_mode_enabled ? aws_elasticache_replication_group.cluster[0].configuration_endpoint_address : aws_elasticache_replication_group.main[0].primary_endpoint_address
}

output "reader_endpoint_address" {
  description = "Reader endpoint address (non-cluster mode only)"
  value       = var.cluster_mode_enabled ? null : aws_elasticache_replication_group.main[0].reader_endpoint_address
}

output "configuration_endpoint_address" {
  description = "Configuration endpoint address (cluster mode only)"
  value       = var.cluster_mode_enabled ? aws_elasticache_replication_group.cluster[0].configuration_endpoint_address : null
}

output "port" {
  description = "Redis port"
  value       = 6379
}

output "security_group_id" {
  description = "Security group ID for Redis"
  value       = aws_security_group.redis.id
}

output "subnet_group_name" {
  description = "ElastiCache subnet group name"
  value       = aws_elasticache_subnet_group.main.name
}

output "parameter_group_name" {
  description = "ElastiCache parameter group name"
  value       = aws_elasticache_parameter_group.main.name
}

output "kms_key_id" {
  description = "KMS key ID for encryption"
  value       = aws_kms_key.redis.id
}

output "kms_key_arn" {
  description = "KMS key ARN for encryption"
  value       = aws_kms_key.redis.arn
}

output "connection_string" {
  description = "Redis connection string (without auth token)"
  value       = var.cluster_mode_enabled ? "redis://${aws_elasticache_replication_group.cluster[0].configuration_endpoint_address}:6379" : "redis://${aws_elasticache_replication_group.main[0].primary_endpoint_address}:6379"
}

output "cluster_enabled" {
  description = "Whether cluster mode is enabled"
  value       = var.cluster_mode_enabled
}
