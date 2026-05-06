# App Runner Outputs

output "service_url" {
  description = "App Runner service URL"
  value       = var.use_ecr_image ? aws_apprunner_service.main[0].service_url : ""
}

output "service_arn" {
  description = "App Runner service ARN"
  value       = var.use_ecr_image ? aws_apprunner_service.main[0].arn : ""
}

output "service_id" {
  description = "App Runner service ID"
  value       = var.use_ecr_image ? aws_apprunner_service.main[0].service_id : ""
}

output "ecr_repository_url" {
  description = "ECR repository URL for pushing images"
  value       = aws_ecr_repository.main.repository_url
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.main.name
}

# These outputs maintain compatibility with the ECS workflow
output "ecs_cluster_name" {
  description = "Placeholder for ECS cluster (not used in App Runner)"
  value       = "apprunner-${var.name}"
}

output "ecs_service_name" {
  description = "Placeholder for ECS service (not used in App Runner)"
  value       = var.name
}
