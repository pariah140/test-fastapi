/**
 * CDN Static Module
 *
 * S3 + CloudFront for static assets (Next.js, React, etc.)
 *
 * Features:
 * - S3 bucket with encryption
 * - CloudFront distribution with custom domain
 * - Origin Access Identity (OAI) for private bucket
 * - Cache behaviors for _next/static/
 * - Price class configuration
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

# S3 Bucket for static assets
resource "aws_s3_bucket" "assets" {
  bucket        = "${var.name}-${var.environment}-assets"
  force_destroy = true

  tags = merge(var.tags, {
    Name = "${var.name}-${var.environment}-assets"
  })
}

# S3 bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.assets.arn
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket policy for CloudFront OAI
resource "aws_s3_bucket_policy" "assets" {
  bucket = aws_s3_bucket.assets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOAI"
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.main.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.assets.arn}/*"
      }
    ]
  })
}

# CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "main" {
  comment = "${var.name}-${var.environment} OAI"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.name}-${var.environment} CDN"
  default_root_object = var.default_root_object
  price_class         = var.price_class
  aliases             = var.domain_aliases

  origin {
    domain_name = aws_s3_bucket.assets.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.assets.id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
    }
  }

  # Default cache behavior
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.assets.id}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = var.default_ttl
    max_ttl     = var.max_ttl
  }

  # Cache behavior for _next/static/ (Next.js)
  dynamic "ordered_cache_behavior" {
    for_each = var.enable_nextjs_optimization ? [1] : []

    content {
      path_pattern           = "_next/static/*"
      allowed_methods        = ["GET", "HEAD"]
      cached_methods         = ["GET", "HEAD"]
      target_origin_id       = "S3-${aws_s3_bucket.assets.id}"
      viewer_protocol_policy = "https-only"
      compress               = true

      forwarded_values {
        query_string = false
        cookies {
          forward = "none"
        }
      }

      min_ttl     = 31536000  # 1 year
      default_ttl = 31536000
      max_ttl     = 31536000
    }
  }

  # Restrictions
  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  # SSL certificate
  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # Logging
  dynamic "logging_config" {
    for_each = var.enable_logging ? [1] : []

    content {
      bucket          = aws_s3_bucket.logs[0].bucket_domain_name
      include_cookies = false
      prefix          = "cloudfront/"
    }
  }

  tags = var.tags
}

# S3 bucket for logs (optional)
resource "aws_s3_bucket" "logs" {
  count = var.enable_logging ? 1 : 0

  bucket        = "${var.name}-${var.environment}-cdn-logs"
  force_destroy = true

  tags = merge(var.tags, {
    Name = "${var.name}-${var.environment}-cdn-logs"
  })
}

# KMS key for encryption
resource "aws_kms_key" "assets" {
  description             = "${var.name}-${var.environment} S3 assets encryption key"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = var.tags
}

resource "aws_kms_alias" "assets" {
  name          = "alias/${var.name}-${var.environment}-assets"
  target_key_id = aws_kms_key.assets.key_id
}

# Data sources
data "aws_region" "current" {}
