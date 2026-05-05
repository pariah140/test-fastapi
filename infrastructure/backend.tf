# Terraform Backend Configuration
# S3 backend for state storage
# The bucket is auto-created by the GitHub Actions workflow if it doesn't exist.
# Bucket name is passed via -backend-config during terraform init.

terraform {
  backend "s3" {
    # Bucket name is passed dynamically via -backend-config="bucket=..."
    key            = "galleon/test-fastapi/production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

# Provider configuration
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Application = "test-fastapi"
      Environment = "production"
      DeployedBy  = "Galleon"
    }
  }
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}
