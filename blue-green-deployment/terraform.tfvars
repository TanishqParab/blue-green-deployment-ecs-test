# General Settings
aws_region  = "us-east-1"
environment = "dev"
project     = "blue-green-deployment"

# VPC Settings
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
availability_zones  = ["us-east-1a", "us-east-1b"]
vpc_name            = "Main VPC"
enable_dns_support  = true
enable_dns_hostnames = true
create_private_subnets = false
# private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
# create_nat_gateway = false

# ALB Settings
alb_name             = "blue-green-alb"
listener_port        = 80
listener_protocol    = "HTTP"
health_check_path    = "/health"
health_check_interval = 30
health_check_timeout  = 10
healthy_threshold     = 3
unhealthy_threshold   = 2
target_group_port     = 5000
create_https_listener = false
# certificate_arn     = "arn:aws:acm:us-east-1:123456789012:certificate/abcdef-1234-5678-abcd-12345678"

# Security Group Settings
security_group_name        = "ECS Security Group"
security_group_description = "Security group for ECS tasks"
ingress_rules = [
  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  },
  {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Flask application port"
  },
  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP traffic"
  }
]

# ECR Settings
repository_name     = "blue-green-app"
image_name          = "blue-green-app"
skip_docker_build   = false
image_tag_mutability = "MUTABLE"
scan_on_push        = true

# ECS Settings
ecs_cluster_name    = "blue-green-cluster"
task_family         = "blue-green-task"
task_role_arn       = "arn:aws:iam::680549841444:role/ecs-task-execution-role"
cpu                 = "256"
memory              = "512"
container_name      = "blue-green-container"
container_port      = 80
desired_count       = 1
ecs_task_definition = "blue-green-task-def"
execution_role_name = "ecs-task-execution-role"
blue_service_name   = "blue-service"
green_service_name  = "green-service"
enable_container_insights = false
enable_container_logs = false
log_group_name      = "/ecs/blue-green-app"
log_retention_days  = 30
deployment_maximum_percent = 200
deployment_minimum_healthy_percent = 100
health_check_grace_period_seconds = 60

# Additional Tags
additional_tags = {
  Environment = "Production"
  Project     = "Blue-Green Deployment"
  ManagedBy   = "Terraform"
  Owner       = "DevOps Team"
}