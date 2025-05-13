############################################
# Provider Configuration
############################################

provider "aws" {
  region = var.aws_region != null ? var.aws_region : var.aws.region
}

############################################
# Local Variables
############################################

locals {
  # Maintain backward compatibility while supporting new variable structure
  aws_region           = var.aws_region != null ? var.aws_region : var.aws.region
  environment          = var.environment != null ? var.environment : lookup(var.aws.tags, "Environment", "dev")
  project              = var.project != null ? var.project : lookup(var.aws.tags, "Project", "blue-green-deployment")
  
  # VPC variables
  vpc_cidr             = var.vpc_cidr != null ? var.vpc_cidr : var.vpc.cidr_block
  vpc_name             = var.vpc_name != null ? var.vpc_name : var.vpc.name
  public_subnet_cidrs  = length(var.public_subnet_cidrs) > 0 ? var.public_subnet_cidrs : var.vpc.public_subnet_cidrs
  availability_zones   = length(var.availability_zones) > 0 ? var.availability_zones : var.vpc.availability_zones
  enable_dns_support   = var.enable_dns_support != null ? var.enable_dns_support : var.vpc.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames != null ? var.enable_dns_hostnames : var.vpc.enable_dns_hostnames
  create_private_subnets = var.create_private_subnets != null ? var.create_private_subnets : var.vpc.create_private_subnets
  private_subnet_cidrs   = length(var.private_subnet_cidrs) > 0 ? var.private_subnet_cidrs : var.vpc.private_subnet_cidrs
  create_nat_gateway     = var.create_nat_gateway != null ? var.create_nat_gateway : var.vpc.create_nat_gateway
  
  # Security group variables
  security_group_name        = var.security_group_name != null ? var.security_group_name : var.security_group.name
  security_group_description = var.security_group_description != null ? var.security_group_description : var.security_group.description
  ingress_rules              = length(var.ingress_rules) > 0 ? var.ingress_rules : var.security_group.ingress_rules
  
  # ALB variables
  alb_name              = var.alb_name != null ? var.alb_name : var.alb.name
  listener_port         = var.listener_port != null ? var.listener_port : var.alb.listener_port
  listener_protocol     = var.listener_protocol != null ? var.listener_protocol : var.alb.listener_protocol
  health_check_path     = var.health_check_path != null ? var.health_check_path : var.alb.health_check_path
  health_check_interval = var.health_check_interval != null ? var.health_check_interval : var.alb.health_check_interval
  health_check_timeout  = var.health_check_timeout != null ? var.health_check_timeout : var.alb.health_check_timeout
  healthy_threshold     = var.healthy_threshold != null ? var.healthy_threshold : var.alb.healthy_threshold
  unhealthy_threshold   = var.unhealthy_threshold != null ? var.unhealthy_threshold : var.alb.unhealthy_threshold
  target_group_port     = var.target_group_port != null ? var.target_group_port : var.alb.target_group_port
  create_https_listener = var.create_https_listener != null ? var.create_https_listener : var.alb.create_https_listener
  certificate_arn       = var.certificate_arn != "" ? var.certificate_arn : var.alb.certificate_arn
  
  # ECR variables
  repository_name      = var.repository_name != null ? var.repository_name : var.ecr.repository_name
  image_name           = var.image_name != null ? var.image_name : var.ecr.image_name
  skip_docker_build    = var.skip_docker_build != null ? var.skip_docker_build : var.ecr.skip_docker_build
  image_tag_mutability = var.image_tag_mutability != null ? var.image_tag_mutability : var.ecr.image_tag_mutability
  scan_on_push         = var.scan_on_push != null ? var.scan_on_push : var.ecr.scan_on_push
  
  # ECS variables
  ecs_cluster_name       = var.ecs_cluster_name != null ? var.ecs_cluster_name : var.ecs.cluster_name
  task_family            = var.task_family != null ? var.task_family : var.ecs.task_family
  task_role_arn          = var.task_role_arn != null ? var.task_role_arn : var.ecs.task_role_arn
  cpu                    = var.cpu != null ? var.cpu : var.ecs.cpu
  memory                 = var.memory != null ? var.memory : var.ecs.memory
  container_name         = var.container_name != null ? var.container_name : var.ecs.container_name
  container_port         = var.container_port != null ? var.container_port : var.ecs.container_port
  desired_count          = var.desired_count != null ? var.desired_count : var.ecs.desired_count
  execution_role_name    = var.execution_role_name != null ? var.execution_role_name : var.ecs.execution_role_name
  blue_service_name      = var.blue_service_name != null ? var.blue_service_name : var.ecs.blue_service_name
  green_service_name     = var.green_service_name != null ? var.green_service_name : var.ecs.green_service_name
  ecs_task_definition    = var.ecs_task_definition != null ? var.ecs_task_definition : var.ecs.task_definition
  
  # Pipeline variables
  blue_target_group_arn  = var.blue_target_group_arn != null ? var.blue_target_group_arn : try(var.pipeline.blue_target_group_arn, null)
  green_target_group_arn = var.green_target_group_arn != null ? var.green_target_group_arn : try(var.pipeline.green_target_group_arn, null)
  
  # Common tags
  common_tags = merge(
    var.aws.tags,
    {
      Environment = local.environment
      Project     = local.project
      ManagedBy   = "Terraform"
    },
    var.additional_tags
  )
}

############################################
# VPC Module
############################################

module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = local.vpc_cidr
  public_subnet_cidrs  = local.public_subnet_cidrs
  availability_zones   = local.availability_zones
  vpc_name             = local.vpc_name
  enable_dns_support   = local.enable_dns_support
  enable_dns_hostnames = local.enable_dns_hostnames
  environment          = local.environment
  additional_tags      = local.common_tags

  # Private subnet configuration
  create_private_subnets = local.create_private_subnets
  private_subnet_cidrs   = local.private_subnet_cidrs
  create_nat_gateway     = local.create_nat_gateway
}

############################################
# Security Group Module
############################################

module "security_group" {
  source                     = "./modules/security_group"
  vpc_id                     = module.vpc.vpc_id
  security_group_name        = local.security_group_name
  security_group_description = local.security_group_description
  ingress_rules              = local.ingress_rules
  additional_tags            = local.common_tags
}

############################################
# ALB Module
############################################

module "alb" {
  source                = "./modules/alb"
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  ecs_security_group_id = module.security_group.ecs_security_group_id
  alb_name              = local.alb_name
  listener_port         = local.listener_port
  listener_protocol     = local.listener_protocol
  health_check_path     = local.health_check_path
  health_check_interval = local.health_check_interval
  health_check_timeout  = local.health_check_timeout
  healthy_threshold     = local.healthy_threshold
  unhealthy_threshold   = local.unhealthy_threshold
  target_group_port     = local.target_group_port
  environment           = local.environment
  create_https_listener = local.create_https_listener
  certificate_arn       = local.certificate_arn
  additional_tags       = local.common_tags
}

############################################
# ECR Module
############################################

module "ecr" {
  source               = "./modules/ecr"
  repository_name      = local.repository_name
  app_py_path          = "${path.module}/modules/ecs/scripts/app.py"
  dockerfile_path      = "${path.module}/modules/ecs/scripts/Dockerfile"
  aws_region           = local.aws_region
  image_name           = local.image_name
  skip_docker_build    = local.skip_docker_build
  image_tag_mutability = local.image_tag_mutability
  scan_on_push         = local.scan_on_push
  additional_tags      = local.common_tags
}

############################################
# ECS Module
############################################

module "ecs" {
  source = "./modules/ecs"

  # Required parameters
  ecs_cluster_name       = local.ecs_cluster_name
  task_family            = local.task_family
  task_role_arn          = local.task_role_arn
  cpu                    = local.cpu
  memory                 = local.memory
  container_name         = local.container_name
  container_image        = module.ecr.image_url
  container_port         = local.container_port
  desired_count          = local.desired_count
  public_subnet_ids      = module.vpc.public_subnet_ids
  ecs_security_group_id  = module.security_group.ecs_security_group_id
  blue_target_group_arn  = local.blue_target_group_arn != null ? local.blue_target_group_arn : module.alb.blue_target_group_arn
  green_target_group_arn = local.green_target_group_arn != null ? local.green_target_group_arn : module.alb.green_target_group_arn
  ecs_task_definition    = local.ecs_task_definition

  # Optional parameters with defaults in the module
  execution_role_name = local.execution_role_name
  blue_service_name   = local.blue_service_name
  green_service_name  = local.green_service_name
  additional_tags     = local.common_tags

  depends_on = [module.alb, module.ecr]
}