/**
 * RDS Proxy Configuration
 *
 * Provides connection pooling and IAM authentication for RDS PostgreSQL.
 * Benefits:
 * - Connection pooling reduces database load
 * - IAM authentication eliminates password management
 * - Automatic failover support
 * - TLS encryption required
 */

# RDS Proxy (optional - enabled via variable)
resource "aws_db_proxy" "main" {
  count = var.enable_rds_proxy ? 1 : 0

  name                   = "${var.name}-${var.environment}-proxy"
  debug_logging          = var.proxy_debug_logging
  engine_family          = "POSTGRESQL"
  idle_client_timeout    = var.proxy_idle_timeout
  require_tls            = true
  role_arn               = aws_iam_role.rds_proxy[0].arn
  vpc_security_group_ids = [aws_security_group.proxy[0].id]
  vpc_subnet_ids         = var.subnet_ids

  auth {
    auth_scheme               = "SECRETS"
    client_password_auth_type = "POSTGRES_SCRAM_SHA_256"
    iam_auth                  = var.proxy_iam_auth ? "REQUIRED" : "DISABLED"
    secret_arn                = aws_secretsmanager_secret.db_master_password.arn
  }

  tags = merge(var.tags, {
    Name = "${var.name}-${var.environment}-proxy"
  })

  depends_on = [aws_db_instance.main]
}

# Proxy target group
resource "aws_db_proxy_default_target_group" "main" {
  count = var.enable_rds_proxy ? 1 : 0

  db_proxy_name = aws_db_proxy.main[0].name

  connection_pool_config {
    connection_borrow_timeout    = var.proxy_connection_borrow_timeout
    max_connections_percent      = var.proxy_max_connections_percent
    max_idle_connections_percent = var.proxy_max_idle_connections_percent
  }
}

# Register RDS instance as proxy target
resource "aws_db_proxy_target" "main" {
  count = var.enable_rds_proxy ? 1 : 0

  db_proxy_name          = aws_db_proxy.main[0].name
  target_group_name      = aws_db_proxy_default_target_group.main[0].name
  db_instance_identifier = aws_db_instance.main.identifier
}

# Security Group for RDS Proxy
resource "aws_security_group" "proxy" {
  count = var.enable_rds_proxy ? 1 : 0

  name        = "${var.name}-${var.environment}-proxy-sg"
  description = "Security group for ${var.name}-${var.environment} RDS Proxy"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name}-${var.environment}-proxy-sg"
  })
}

# Allow inbound from application security groups to proxy
resource "aws_security_group_rule" "proxy_ingress" {
  for_each = var.enable_rds_proxy ? toset(var.allowed_security_group_ids) : []

  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = each.value
  security_group_id        = aws_security_group.proxy[0].id
  description              = "PostgreSQL access from application via proxy"
}

# Allow proxy to connect to RDS
resource "aws_security_group_rule" "proxy_to_rds" {
  count = var.enable_rds_proxy ? 1 : 0

  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.db.id
  security_group_id        = aws_security_group.proxy[0].id
  description              = "Allow proxy to connect to RDS"
}

# Allow RDS to receive from proxy
resource "aws_security_group_rule" "rds_from_proxy" {
  count = var.enable_rds_proxy ? 1 : 0

  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.proxy[0].id
  security_group_id        = aws_security_group.db.id
  description              = "PostgreSQL access from RDS Proxy"
}

# IAM Role for RDS Proxy
resource "aws_iam_role" "rds_proxy" {
  count = var.enable_rds_proxy ? 1 : 0

  name = "${var.name}-${var.environment}-rds-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# Policy for RDS Proxy to access Secrets Manager
resource "aws_iam_role_policy" "rds_proxy_secrets" {
  count = var.enable_rds_proxy ? 1 : 0

  name = "${var.name}-${var.environment}-rds-proxy-secrets"
  role = aws_iam_role.rds_proxy[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          aws_secretsmanager_secret.db_master_password.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = [
          aws_kms_key.db.arn
        ]
        Condition = {
          StringEquals = {
            "kms:ViaService" = "secretsmanager.${data.aws_region.current.name}.amazonaws.com"
          }
        }
      }
    ]
  })
}

# IAM Policy for application to use IAM auth with RDS Proxy
resource "aws_iam_policy" "rds_iam_auth" {
  count = var.enable_rds_proxy && var.proxy_iam_auth ? 1 : 0

  name        = "${var.name}-${var.environment}-rds-iam-auth"
  description = "Allow IAM authentication to RDS Proxy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-db:connect"
        ]
        Resource = [
          "arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_proxy.main[0].id}/${var.iam_db_username}"
        ]
      }
    ]
  })
}

# Data source for account ID
data "aws_caller_identity" "current" {}
