/**
 * ElastiCache Redis Module
 *
 * Production-ready Redis cluster with:
 * - Automatic failover (if cluster_mode_enabled)
 * - Encryption in transit and at rest
 * - Automated backups
 * - CloudWatch monitoring
 * - Multi-AZ support
 */

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Security Group
resource "aws_security_group" "redis" {
  name        = "${var.name}-${var.environment}-redis-sg"
  description = "Security group for ${var.name}-${var.environment} Redis cluster"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name}-${var.environment}-redis-sg"
  })
}

# Allow inbound from application security groups
resource "aws_security_group_rule" "redis_ingress" {
  for_each = toset(var.allowed_security_group_ids)

  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = each.value
  security_group_id        = aws_security_group.redis.id
  description              = "Redis access from application"
}

# Allow outbound
resource "aws_security_group_rule" "redis_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.redis.id
  description       = "Allow all outbound traffic"
}

# Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.name}-${var.environment}-redis-subnet"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name}-${var.environment}-redis-subnet"
  })
}

# Parameter Group
resource "aws_elasticache_parameter_group" "main" {
  name   = "${var.name}-${var.environment}-redis-params"
  family = var.parameter_group_family

  # Custom parameters
  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = var.tags
}

# KMS Key for encryption
resource "aws_kms_key" "redis" {
  description             = "${var.name}-${var.environment} Redis encryption key"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = var.tags
}

resource "aws_kms_alias" "redis" {
  name          = "alias/${var.name}-${var.environment}-redis"
  target_key_id = aws_kms_key.redis.key_id
}

# Redis Replication Group (cluster mode disabled)
resource "aws_elasticache_replication_group" "main" {
  count = var.cluster_mode_enabled ? 0 : 1

  replication_group_id = "${var.name}-${var.environment}-redis"
  description          = "${var.name}-${var.environment} Redis cluster"

  # Engine
  engine               = "redis"
  engine_version       = var.redis_version
  node_type            = var.node_type
  port                 = 6379
  parameter_group_name = aws_elasticache_parameter_group.main.name

  # Replication
  num_cache_clusters         = var.num_cache_nodes
  automatic_failover_enabled = var.num_cache_nodes > 1
  multi_az_enabled           = var.multi_az_enabled

  # Network
  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.redis.id]

  # Encryption
  at_rest_encryption_enabled = true
  kms_key_id                 = aws_kms_key.redis.arn
  transit_encryption_enabled = var.transit_encryption_enabled

  # Backups
  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window          = var.snapshot_window
  maintenance_window       = var.maintenance_window
  final_snapshot_identifier = var.create_final_snapshot ? "${var.name}-${var.environment}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}" : null

  # Notifications
  notification_topic_arn = var.notification_topic_arn

  # Upgrades
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  apply_immediately          = var.apply_immediately

  # Logging
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.slow_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.engine_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }

  tags = merge(var.tags, {
    Name = "${var.name}-${var.environment}-redis"
  })

  lifecycle {
    ignore_changes = [
      final_snapshot_identifier
    ]
  }
}

# Redis Replication Group (cluster mode enabled)
resource "aws_elasticache_replication_group" "cluster" {
  count = var.cluster_mode_enabled ? 1 : 0

  replication_group_id = "${var.name}-${var.environment}-redis"
  description          = "${var.name}-${var.environment} Redis cluster (cluster mode)"

  # Engine
  engine               = "redis"
  engine_version       = var.redis_version
  node_type            = var.node_type
  port                 = 6379
  parameter_group_name = aws_elasticache_parameter_group.main.name

  # Cluster mode configuration
  num_node_groups         = var.num_node_groups
  replicas_per_node_group = var.replicas_per_node_group
  automatic_failover_enabled = true
  multi_az_enabled           = true

  # Network
  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.redis.id]

  # Encryption
  at_rest_encryption_enabled = true
  kms_key_id                 = aws_kms_key.redis.arn
  transit_encryption_enabled = var.transit_encryption_enabled

  # Backups
  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window          = var.snapshot_window
  maintenance_window       = var.maintenance_window
  final_snapshot_identifier = var.create_final_snapshot ? "${var.name}-${var.environment}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}" : null

  # Notifications
  notification_topic_arn = var.notification_topic_arn

  # Upgrades
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  apply_immediately          = var.apply_immediately

  # Logging
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.slow_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.engine_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }

  tags = merge(var.tags, {
    Name = "${var.name}-${var.environment}-redis"
  })

  lifecycle {
    ignore_changes = [
      final_snapshot_identifier
    ]
  }
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "slow_log" {
  name              = "/aws/elasticache/${var.name}-${var.environment}/slow-log"
  retention_in_days = var.cloudwatch_logs_retention

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "engine_log" {
  name              = "/aws/elasticache/${var.name}-${var.environment}/engine-log"
  retention_in_days = var.cloudwatch_logs_retention

  tags = var.tags
}

# Data sources
data "aws_region" "current" {}
