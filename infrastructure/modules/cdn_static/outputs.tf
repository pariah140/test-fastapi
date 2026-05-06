/**
 * CDN Static Module - Outputs
 */

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.main.id
}

output "cloudfront_distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.main.arn
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_hosted_zone_id" {
  description = "CloudFront distribution hosted zone ID"
  value       = aws_cloudfront_distribution.main.hosted_zone_id
}

output "s3_bucket_id" {
  description = "S3 bucket ID"
  value       = aws_s3_bucket.assets.id
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.assets.arn
}

output "s3_bucket_domain_name" {
  description = "S3 bucket domain name"
  value       = aws_s3_bucket.assets.bucket_domain_name
}

output "s3_bucket_regional_domain_name" {
  description = "S3 bucket regional domain name"
  value       = aws_s3_bucket.assets.bucket_regional_domain_name
}

output "kms_key_id" {
  description = "KMS key ID for S3 encryption"
  value       = aws_kms_key.assets.id
}

output "kms_key_arn" {
  description = "KMS key ARN for S3 encryption"
  value       = aws_kms_key.assets.arn
}

output "origin_access_identity_iam_arn" {
  description = "CloudFront Origin Access Identity IAM ARN"
  value       = aws_cloudfront_origin_access_identity.main.iam_arn
}

output "logs_bucket_id" {
  description = "Logs S3 bucket ID (if logging enabled)"
  value       = var.enable_logging ? aws_s3_bucket.logs[0].id : null
}
