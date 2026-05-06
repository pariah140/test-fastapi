/**
 * RDS PostgreSQL Module - Outputs
 */

output "db_instance_id" {
  description = "RDS instance identifier"
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.main.arn
}

output "db_instance_endpoint" {
  description = "Connection endpoint (host:port)"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_address" {
  description = "Database hostname"
  value       = aws_db_instance.main.address
}

output "db_instance_port" {
  description = "Database port"
  value       = aws_db_instance.main.port
}

output "db_instance_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}

output "db_master_username" {
  description = "Master username"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "db_security_group_id" {
  description = "Security group ID for the database"
  value       = aws_security_group.db.id
}

output "db_subnet_group_name" {
  description = "DB subnet group name"
  value       = aws_db_subnet_group.main.name
}

output "db_parameter_group_name" {
  description = "DB parameter group name"
  value       = aws_db_parameter_group.main.name
}

output "kms_key_id" {
  description = "KMS key ID for encryption"
  value       = aws_kms_key.db.id
}

output "kms_key_arn" {
  description = "KMS key ARN for encryption"
  value       = aws_kms_key.db.arn
}

output "secret_arn" {
  description = "Secrets Manager secret ARN containing master password"
  value       = aws_secretsmanager_secret.db_master_password.arn
}

output "secret_name" {
  description = "Secrets Manager secret name"
  value       = aws_secretsmanager_secret.db_master_password.name
}

output "connection_string" {
  description = "Database connection string (without password)"
  value       = "postgresql://${aws_db_instance.main.username}@${aws_db_instance.main.address}:${aws_db_instance.main.port}/${aws_db_instance.main.db_name}"
  sensitive   = true
}

# RDS Proxy outputs
output "proxy_endpoint" {
  description = "RDS Proxy endpoint (use this instead of direct RDS endpoint when proxy is enabled)"
  value       = var.enable_rds_proxy ? aws_db_proxy.main[0].endpoint : null
}

output "proxy_arn" {
  description = "RDS Proxy ARN"
  value       = var.enable_rds_proxy ? aws_db_proxy.main[0].arn : null
}

output "proxy_security_group_id" {
  description = "Security group ID for RDS Proxy"
  value       = var.enable_rds_proxy ? aws_security_group.proxy[0].id : null
}

output "iam_auth_policy_arn" {
  description = "IAM policy ARN for RDS IAM authentication (attach to ECS task role)"
  value       = var.enable_rds_proxy && var.proxy_iam_auth ? aws_iam_policy.rds_iam_auth[0].arn : null
}

output "connection_endpoint" {
  description = "Recommended connection endpoint (proxy if enabled, otherwise direct RDS)"
  value       = var.enable_rds_proxy ? aws_db_proxy.main[0].endpoint : aws_db_instance.main.address
}
