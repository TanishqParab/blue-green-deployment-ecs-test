# Output variables for Jenkins pipeline compatibility

output "ecs_cluster_id" {
  description = "The ID/name of the ECS cluster (for Jenkins pipeline compatibility)"
  value       = module.ecs.cluster_name
}

output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.alb.alb_dns_name
}

output "blue_target_group_arn" {
  description = "The ARN of the blue target group"
  value       = module.alb.blue_target_group_arn
}

output "green_target_group_arn" {
  description = "The ARN of the green target group"
  value       = module.alb.green_target_group_arn
}

output "blue_service_name" {
  description = "The name of the blue ECS service"
  value       = module.ecs.blue_service_name
}

output "green_service_name" {
  description = "The name of the green ECS service"
  value       = module.ecs.green_service_name
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = module.ecr.image_url
}