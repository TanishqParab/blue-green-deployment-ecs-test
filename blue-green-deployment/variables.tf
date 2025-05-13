############################################
# Global Configuration Variables
############################################

variable "aws" {
  description = "AWS configuration settings"
  type = object({
    region = string
    tags   = map(string)
  })
  default = {
    region = "us-east-1"
    tags   = {
      Environment = "dev"
      Project     = "blue-green-deployment"
      ManagedBy   = "Terraform"
    }
  }
}

# For backward compatibility
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name for tagging resources"
  type        = string
  default     = "blue-green-deployment"
}

variable "additional_tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
  }
}

############################################
# VPC Configuration Variables
############################################

variable "vpc" {
  description = "VPC configuration settings"
  type = object({
    cidr_block           = string
    name                 = string
    public_subnet_cidrs  = list(string)
    availability_zones   = list(string)
    enable_dns_support   = bool
    enable_dns_hostnames = bool
    create_private_subnets = bool
    private_subnet_cidrs   = list(string)
    create_nat_gateway     = bool
  })
  default = {
    cidr_block           = "10.0.0.0/16"
    name                 = "Main VPC"
    public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
    availability_zones   = ["us-east-1a", "us-east-1b"]
    enable_dns_support   = true
    enable_dns_hostnames = true
    create_private_subnets = false
    private_subnet_cidrs   = []
    create_nat_gateway     = false
  }
}

# For backward compatibility
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "Main VPC"
}

variable "enable_dns_support" {
  description = "Enable DNS support for the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames for the VPC"
  type        = bool
  default     = true
}

variable "create_private_subnets" {
  description = "Whether to create private subnets"
  type        = bool
  default     = false
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = []
}

variable "create_nat_gateway" {
  description = "Whether to create a NAT Gateway for private subnets"
  type        = bool
  default     = false
}

############################################
# ALB Configuration Variables
############################################

variable "alb" {
  description = "ALB configuration settings"
  type = object({
    name                 = string
    listener_port        = number
    listener_protocol    = string
    health_check_path    = string
    health_check_interval = number
    health_check_timeout  = number
    healthy_threshold     = number
    unhealthy_threshold   = number
    target_group_port     = number
    create_https_listener = bool
    certificate_arn       = string
  })
  default = {
    name                 = "blue-green-alb"
    listener_port        = 80
    listener_protocol    = "HTTP"
    health_check_path    = "/health"
    health_check_interval = 30
    health_check_timeout  = 10
    healthy_threshold     = 3
    unhealthy_threshold   = 2
    target_group_port     = 5000
    create_https_listener = false
    certificate_arn       = ""
  }
}

# For backward compatibility
variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = "blue-green-alb"
}

variable "listener_port" {
  description = "Port for the ALB listener"
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "Protocol for the ALB listener (HTTP or HTTPS)"
  type        = string
  default     = "HTTP"
}

variable "health_check_path" {
  description = "The health check path for the target groups"
  type        = string
  default     = "/health"
}

variable "health_check_interval" {
  description = "The interval (in seconds) between health checks"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "The timeout (in seconds) for each health check"
  type        = number
  default     = 10
}

variable "healthy_threshold" {
  description = "The number of successful health checks required to mark a target as healthy"
  type        = number
  default     = 3
}

variable "unhealthy_threshold" {
  description = "The number of failed health checks required to mark a target as unhealthy"
  type        = number
  default     = 2
}

variable "target_group_port" {
  description = "Port for the target groups"
  type        = number
  default     = 5000
}

variable "create_https_listener" {
  description = "Whether to create an HTTPS listener"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS listener"
  type        = string
  default     = ""
}

############################################
# Security Group Configuration Variables
############################################

variable "security_group" {
  description = "Security group configuration settings"
  type = object({
    name        = string
    description = string
    ingress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
      description = optional(string)
    }))
  })
  default = {
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
}

# For backward compatibility
variable "security_group_name" {
  description = "Name of the security group"
  type        = string
  default     = "ECS Security Group"
}

variable "security_group_description" {
  description = "Description of the security group"
  type        = string
  default     = "Security group for ECS tasks"
}

variable "ingress_rules" {
  description = "List of ingress rules for the security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = optional(string)
  }))
  default = [
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

############################################
# ECR Configuration Variables
############################################

variable "ecr" {
  description = "ECR configuration settings"
  type = object({
    repository_name      = string
    image_name           = string
    skip_docker_build    = bool
    image_tag_mutability = string
    scan_on_push         = bool
  })
  default = {
    repository_name      = "blue-green-app"
    image_name           = "blue-green-app"
    skip_docker_build    = false
    image_tag_mutability = "MUTABLE"
    scan_on_push         = true
  }
}

# For backward compatibility
variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "blue-green-app"
}

variable "image_name" {
  description = "Name for the Docker image"
  type        = string
  default     = "blue-green-app"
}

variable "skip_docker_build" {
  description = "Whether to skip Docker build and push"
  type        = bool
  default     = false
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Whether to scan images on push"
  type        = bool
  default     = true
}

############################################
# ECS Configuration Variables
############################################

variable "ecs" {
  description = "ECS configuration settings"
  type = object({
    cluster_name         = string
    task_family          = string
    task_role_arn        = string
    cpu                  = string
    memory               = string
    container_name       = string
    container_port       = number
    desired_count        = number
    execution_role_name  = string
    blue_service_name    = string
    green_service_name   = string
    task_definition      = string
    enable_container_insights = bool
    enable_container_logs     = bool
    log_group_name            = string
    log_retention_days        = number
    container_environment     = list(object({
      name  = string
      value = string
    }))
    deployment_maximum_percent = number
    deployment_minimum_healthy_percent = number
    health_check_grace_period_seconds = number
  })
  default = {
    cluster_name         = "blue-green-cluster"
    task_family          = "blue-green-task"
    task_role_arn        = null
    cpu                  = "256"
    memory               = "512"
    container_name       = "blue-green-container"
    container_port       = 80
    desired_count        = 1
    execution_role_name  = "ecs-task-execution-role"
    blue_service_name    = "blue-service"
    green_service_name   = "green-service"
    task_definition      = "blue-green-task-def"
    enable_container_insights = false
    enable_container_logs     = false
    log_group_name            = "/ecs/blue-green-app"
    log_retention_days        = 30
    container_environment     = []
    deployment_maximum_percent = 200
    deployment_minimum_healthy_percent = 100
    health_check_grace_period_seconds = 60
  }
}

# For backward compatibility
variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "blue-green-cluster"
}

variable "task_family" {
  description = "Family name for the task definition"
  type        = string
  default     = "blue-green-task"
}

variable "task_role_arn" {
  description = "ARN of the IAM role for the task"
  type        = string
}

variable "cpu" {
  description = "CPU units for the task"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Memory for the task in MB"
  type        = string
  default     = "512"
}

variable "container_name" {
  description = "Name of the container"
  type        = string
  default     = "blue-green-container"
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 80
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}

variable "ecs_task_definition" {
  description = "The ECS task definition for Fargate"
  type        = string
  default     = "blue-green-task-def"
}

variable "execution_role_name" {
  description = "Name of the ECS task execution role"
  type        = string
  default     = "ecs-task-execution-role"
}

variable "blue_service_name" {
  description = "Name of the blue service"
  type        = string
  default     = "blue-service"
}

variable "green_service_name" {
  description = "Name of the green service"
  type        = string
  default     = "green-service"
}

variable "enable_container_insights" {
  description = "Whether to enable CloudWatch Container Insights for the cluster"
  type        = bool
  default     = false
}

variable "enable_container_logs" {
  description = "Whether to enable CloudWatch logs for containers"
  type        = bool
  default     = false
}

variable "log_group_name" {
  description = "Name of the CloudWatch log group for container logs"
  type        = string
  default     = "/ecs/blue-green-app"
}

variable "log_retention_days" {
  description = "Number of days to retain container logs"
  type        = number
  default     = 30
}

variable "container_environment" {
  description = "Environment variables for the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "deployment_maximum_percent" {
  description = "Maximum percentage of tasks that can be running during a deployment"
  type        = number
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum percentage of tasks that must remain healthy during a deployment"
  type        = number
  default     = 100
}

variable "health_check_grace_period_seconds" {
  description = "Seconds to ignore failing load balancer health checks on newly provisioned tasks"
  type        = number
  default     = 60
}

############################################
# Pipeline Integration Variables
############################################

variable "pipeline" {
  description = "Pipeline integration settings"
  type = object({
    blue_target_group_arn  = string
    green_target_group_arn = string
  })
  default = {
    blue_target_group_arn  = null
    green_target_group_arn = null
  }
}

# For backward compatibility
variable "blue_target_group_arn" {
  description = "ARN of the blue target group (used for pipeline integration)"
  type        = string
  default     = null
}

variable "green_target_group_arn" {
  description = "ARN of the green target group (used for pipeline integration)"
  type        = string
  default     = null
}