# Blue-Green Deployment Configuration

aws = {
  region = "us-east-1"
  tags = {
    Environment = "dev"
    Project     = "blue-green-deployment"
    ManagedBy   = "Terraform"
  }
}

# VPC Configuration
vpc = {
  cidr_block           = "10.0.0.0/16"
  name                 = "Main VPC"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
  enable_dns_support   = true
  enable_dns_hostnames = true

  # Private subnet configuration (optional)
  create_private_subnets = false
  private_subnet_cidrs   = []
  create_nat_gateway     = false

  # Additional settings
  instance_tenancy        = "default"
  subnet_name_prefix      = "Public-Subnet"
  igw_name                = "Main-IGW"
  route_table_name        = "Public-RT"
  map_public_ip_on_launch = true

  # Flow logs (optional)
  enable_flow_logs       = false
  flow_logs_traffic_type = "ALL"
}

# Security Group Configuration
security_group = {
  name        = "ECS Security Group"
  description = "Security group for ECS tasks"
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
}

# ALB Configuration
alb = {
  name                  = "blue-green-alb"
  listener_port         = 80
  listener_protocol     = "HTTP"
  health_check_path     = "/health"
  health_check_interval = 30
  health_check_timeout  = 10
  healthy_threshold     = 3
  unhealthy_threshold   = 2
  target_group_port     = 5000
  create_https_listener = false
  certificate_arn       = ""
}

# ECR Configuration
ecr = {
  repository_name      = "blue-green-app"
  image_name           = "blue-green-app"
  skip_docker_build    = false
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
}

# ECS Configuration
ecs = {
  cluster_name        = "blue-green-cluster"
  task_family         = "blue-green-task"
  task_role_arn       =  null # Will be created by the ECS module
  cpu                 = "256"
  memory              = "512"
  container_name      = "blue-green-container"
  container_port      = 80
  desired_count       = 1
  execution_role_name = "ecs-task-execution-role"
  blue_service_name   = "blue-service"
  green_service_name  = "green-service"
  task_definition     = "blue-green-task-def"

  # Optional configurations
  enable_container_insights          = false
  enable_container_logs              = false
  log_group_name                     = "/ecs/blue-green-app"
  log_retention_days                 = 30
  container_environment              = []
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds  = 60
}

# Pipeline Integration
pipeline = {
  blue_target_group_arn  = null
  green_target_group_arn = null
}
