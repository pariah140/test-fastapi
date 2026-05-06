/**
 * RDS PostgreSQL Module
 *
 * Production-ready PostgreSQL with:
 * - Multi-AZ deployment
 * - Automated backups
 * - Encryption at rest and in transit
 * - CloudWatch monitoring
 * - Parameter and subnet groups
 * - Secrets Manager integration
 */

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Random password for master user
resource "random_password" "master" {
  length  = 32
  special = true
  # Avoid characters that might cause issues in connection strings
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store master password in Secrets Manager
resource "aws_secretsmanager_secret" "db_master_password" {
  name                    = "${var.name}-${var.environment}-db-master-password"
  description             = "Master password for ${var.name}-${var.environment} RDS instance"
  recovery_window_in_days = var.secret_recovery_days

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "db_master_password" {
  secret_id = aws_secretsmanager_secret.db_master_password.id
  secret_string = jsonencode({
    username = var.master_username
    password = random_password.master.result
    engine   = "postgres"
    host     = aws_db_instance.main.address
    port     = aws_db_instance.main.port
    dbname   = var.database_name
  })
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.name}-${var.environment}-db-subnet"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name}-${var.environment}-db-subnet"
  })
}

# DB Parameter Group
resource "aws_db_parameter_group" "main" {
  name   = "${var.name}-${var.environment}-pg-params"
  family = var.parameter_group_family

  # Performance and logging parameters
  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", "immediate")
    }
  }

  tags = var.tags
}

# Security Group
resource "aws_security_group" "db" {
  name        = "${var.name}-${var.environment}-db-sg"
  description = "Security group for ${var.name}-${var.environment} RDS instance"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name}-${var.environment}-db-sg"
  })
}

# Allow inbound from application security groups
resource "aws_security_group_rule" "db_ingress" {
  for_each = toset(var.allowed_security_group_ids)

  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = each.value
  security_group_id        = aws_security_group.db.id
  description              = "PostgreSQL access from application"
}

# Allow outbound (for replication, backups, etc.)
resource "aws_security_group_rule" "db_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.db.id
  description       = "Allow all outbound traffic"
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = "${var.name}-${var.environment}-db"

  # Engine
  engine               = "postgres"
  engine_version       = var.postgres_version
  instance_class       = var.instance_class
  allocated_storage    = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type         = var.storage_type
  storage_encrypted    = true
  kms_key_id           = aws_kms_key.db.arn

  # Database
  db_name  = var.database_name
  username = var.master_username
  password = random_password.master.result
  port     = 5432

  # Network
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = var.publicly_accessible

  # High availability
  multi_az               = var.multi_az
  availability_zone      = var.multi_az ? null : var.availability_zone

  # Backups
  backup_retention_period   = var.backup_retention_period
  backup_window             = var.backup_window
  maintenance_window        = var.maintenance_window
  copy_tags_to_snapshot     = true
  delete_automated_backups  = var.delete_automated_backups
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name}-${var.environment}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # Performance Insights
  performance_insights_enabled    = var.enable_performance_insights
  performance_insights_kms_key_id = var.enable_performance_insights ? aws_kms_key.db.arn : null
  performance_insights_retention_period = var.enable_performance_insights ? var.performance_insights_retention : null

  # Monitoring
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring[0].arn : null

  # Parameters
  parameter_group_name = aws_db_parameter_group.main.name

  # Upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately           = var.apply_immediately

  # Deletion protection
  deletion_protection = var.deletion_protection

  tags = merge(var.tags, {
    Name = "${var.name}-${var.environment}-db"
  })

  lifecycle {
    ignore_changes = [
      password,
      final_snapshot_identifier
    ]
  }
}

# KMS Key for encryption
resource "aws_kms_key" "db" {
  description             = "${var.name}-${var.environment} RDS encryption key"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = var.tags
}

resource "aws_kms_alias" "db" {
  name          = "alias/${var.name}-${var.environment}-db"
  target_key_id = aws_kms_key.db.key_id
}

# IAM role for enhanced monitoring
resource "aws_iam_role" "rds_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  name = "${var.name}-${var.environment}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# CloudWatch Log Group (for PostgreSQL logs)
resource "aws_cloudwatch_log_group" "postgresql" {
  count = length(var.enabled_cloudwatch_logs_exports) > 0 ? 1 : 0

  name              = "/aws/rds/instance/${aws_db_instance.main.identifier}/postgresql"
  retention_in_days = var.cloudwatch_logs_retention

  tags = var.tags
}

# Data sources
data "aws_region" "current" {}
