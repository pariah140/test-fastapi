/**
 * ElastiCache Redis Module - Security & Monitoring
 */

# CloudWatch Alarms for Redis monitoring

# CPU Utilization alarm
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = "${var.name}-${var.environment}-redis-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = 300 # 5 minutes
  statistic           = "Average"
  threshold           = 75
  alarm_description   = "Redis CPU utilization is too high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    CacheClusterId = var.cluster_mode_enabled ? null : "${var.name}-${var.environment}-redis"
    ReplicationGroupId = "${var.name}-${var.environment}-redis"
  }

  tags = var.tags
}

# Memory utilization alarm
resource "aws_cloudwatch_metric_alarm" "memory_utilization" {
  alarm_name          = "${var.name}-${var.environment}-redis-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseMemoryUsagePercentage"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Redis memory utilization is too high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ReplicationGroupId = "${var.name}-${var.environment}-redis"
  }

  tags = var.tags
}

# Evictions alarm (indicates memory pressure)
resource "aws_cloudwatch_metric_alarm" "evictions" {
  alarm_name          = "${var.name}-${var.environment}-redis-evictions"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Evictions"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Sum"
  threshold           = 1000
  alarm_description   = "Redis is evicting keys due to memory pressure"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ReplicationGroupId = "${var.name}-${var.environment}-redis"
  }

  tags = var.tags
}

# Replication lag alarm
resource "aws_cloudwatch_metric_alarm" "replication_lag" {
  count = var.num_cache_nodes > 1 || var.cluster_mode_enabled ? 1 : 0

  alarm_name          = "${var.name}-${var.environment}-redis-replication-lag"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ReplicationLag"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = 30 # 30 seconds
  alarm_description   = "Redis replication lag is too high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ReplicationGroupId = "${var.name}-${var.environment}-redis"
  }

  tags = var.tags
}

# Connection count alarm
resource "aws_cloudwatch_metric_alarm" "curr_connections" {
  alarm_name          = "${var.name}-${var.environment}-redis-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CurrConnections"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = 500
  alarm_description   = "Redis connection count is too high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ReplicationGroupId = "${var.name}-${var.environment}-redis"
  }

  tags = var.tags
}

# Engine CPU utilization alarm (Redis-specific)
resource "aws_cloudwatch_metric_alarm" "engine_cpu_utilization" {
  alarm_name          = "${var.name}-${var.environment}-redis-engine-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "EngineCPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Redis engine CPU utilization is too high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ReplicationGroupId = "${var.name}-${var.environment}-redis"
  }

  tags = var.tags
}

# Network bytes in alarm
resource "aws_cloudwatch_metric_alarm" "network_bytes_in" {
  alarm_name          = "${var.name}-${var.environment}-redis-network-in-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "NetworkBytesIn"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = 50000000 # 50 MB
  alarm_description   = "Redis network input is too high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ReplicationGroupId = "${var.name}-${var.environment}-redis"
  }

  tags = var.tags
}

# SNS Topic for alarms (optional - uncomment to enable)
# resource "aws_sns_topic" "redis_alarms" {
#   name = "${var.name}-${var.environment}-redis-alarms"
#   tags = var.tags
# }

# resource "aws_sns_topic_subscription" "redis_alarms_email" {
#   topic_arn = aws_sns_topic.redis_alarms.arn
#   protocol  = "email"
#   endpoint  = var.alarm_email
# }
