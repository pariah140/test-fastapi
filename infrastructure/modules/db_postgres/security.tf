/**
 * RDS PostgreSQL Module - Security & Monitoring
 */

# CloudWatch Alarms for RDS monitoring

# CPU Utilization alarm
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = "${var.name}-${var.environment}-db-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300 # 5 minutes
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS CPU utilization is too high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  tags = var.tags
}

# Database connections alarm
resource "aws_cloudwatch_metric_alarm" "database_connections" {
  alarm_name          = "${var.name}-${var.environment}-db-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80 # Adjust based on instance class
  alarm_description   = "RDS database connections are too high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  tags = var.tags
}

# Free storage space alarm
resource "aws_cloudwatch_metric_alarm" "free_storage_space" {
  alarm_name          = "${var.name}-${var.environment}-db-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 10737418240 # 10 GB in bytes
  alarm_description   = "RDS free storage space is low"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  tags = var.tags
}

# Read latency alarm
resource "aws_cloudwatch_metric_alarm" "read_latency" {
  alarm_name          = "${var.name}-${var.environment}-db-read-latency-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ReadLatency"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 0.1 # 100ms
  alarm_description   = "RDS read latency is too high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  tags = var.tags
}

# Write latency alarm
resource "aws_cloudwatch_metric_alarm" "write_latency" {
  alarm_name          = "${var.name}-${var.environment}-db-write-latency-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "WriteLatency"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 0.1 # 100ms
  alarm_description   = "RDS write latency is too high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  tags = var.tags
}

# Automated snapshot sharing (for cross-region DR)
# Note: This is a placeholder - actual implementation would use AWS Backup or Lambda
resource "aws_db_snapshot" "manual" {
  count = 0 # Disabled by default - use AWS Backup instead

  db_instance_identifier = aws_db_instance.main.id
  db_snapshot_identifier = "${var.name}-${var.environment}-manual-snapshot-${formatdate("YYYY-MM-DD", timestamp())}"

  tags = merge(var.tags, {
    Type = "manual"
  })
}

# SNS Topic for alarms (optional - uncomment to enable)
# resource "aws_sns_topic" "db_alarms" {
#   name = "${var.name}-${var.environment}-db-alarms"
#   tags = var.tags
# }

# resource "aws_sns_topic_subscription" "db_alarms_email" {
#   topic_arn = aws_sns_topic.db_alarms.arn
#   protocol  = "email"
#   endpoint  = var.alarm_email
# }
