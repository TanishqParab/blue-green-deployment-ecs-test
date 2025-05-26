############################################
# VPC Outputs
############################################

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

############################################
# ALB Outputs
############################################

output "alb_id" {
  description = "The ID of the ALB"
  value       = module.alb.alb_id
}

output "alb_arn" {
  description = "The ARN of the ALB"
  value       = module.alb.alb_arn
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
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

output "http_listener_arn" {
  description = "The ARN of the HTTP listener"
  value       = module.alb.http_listener_arn
}

output "https_listener_arn" {
  description = "The ARN of the HTTPS listener (if created)"
  value       = module.alb.https_listener_arn
}

############################################
# ECR Outputs
############################################

output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "ecr_repository_name" {
  description = "The name of the ECR repository"
  value       = module.ecr.repository_name
}

output "image_url" {
  description = "The URL of the Docker image"
  value       = module.ecr.image_url
}

############################################
# ECS Outputs
############################################

output "ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  value       = module.ecs.cluster_id
}

output "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster"
  value       = module.ecs.cluster_arn
}

output "blue_service_id" {
  description = "The ID of the blue ECS service"
  value       = module.ecs.blue_service_id
}

output "green_service_id" {
  description = "The ID of the green ECS service"
  value       = module.ecs.green_service_id
}

output "blue_task_definition_arn" {
  description = "The ARN of the blue task definition"
  value       = module.ecs.blue_task_definition_arn
}

output "execution_role_arn" {
  description = "The ARN of the ECS task execution role"
  value       = module.ecs.execution_role_arn
}

############################################
# Security Group Outputs
############################################

output "ecs_security_group_id" {
  description = "The ID of the ECS security group"
  value       = module.security_group.ecs_security_group_id
}