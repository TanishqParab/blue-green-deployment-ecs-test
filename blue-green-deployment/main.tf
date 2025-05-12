locals {
  common_tags = merge(
    {
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "Terraform"
    },
    var.additional_tags
  )
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source                 = "./modules/vpc"
  vpc_cidr               = var.vpc_cidr
  public_subnet_cidrs    = var.public_subnet_cidrs
  availability_zones     = var.availability_zones
  vpc_name               = var.vpc_name
  enable_dns_support     = var.enable_dns_support
  enable_dns_hostnames   = var.enable_dns_hostnames
  environment            = var.environment
  create_private_subnets = var.create_private_subnets
  private_subnet_cidrs   = var.private_subnet_cidrs
  create_nat_gateway     = var.create_nat_gateway
  additional_tags        = local.common_tags
}

module "security_group" {
  source                   = "./modules/security_group"
  vpc_id                   = module.vpc.vpc_id
  security_group_name      = var.security_group_name
  security_group_description = var.security_group_description
  ingress_rules            = var.ingress_rules
  additional_tags          = local.common_tags
}

module "alb" {
  source                = "./modules/alb"
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  ecs_security_group_id = module.security_group.ecs_security_group_id
  alb_name              = var.alb_name
  listener_port         = var.listener_port
  listener_protocol     = var.listener_protocol
  health_check_path     = var.health_check_path
  health_check_interval = var.health_check_interval
  health_check_timeout  = var.health_check_timeout
  healthy_threshold     = var.healthy_threshold
  unhealthy_threshold   = var.unhealthy_threshold
  target_group_port     = var.target_group_port
  environment           = var.environment
  create_https_listener = var.create_https_listener
  certificate_arn       = var.certificate_arn
  additional_tags       = local.common_tags
}

module "ecr" {
  source              = "./modules/ecr"
  repository_name     = var.repository_name
  app_py_path         = "${path.module}/modules/ecs/scripts/app.py"
  dockerfile_path     = "${path.module}/modules/ecs/scripts/Dockerfile"
  aws_region          = var.aws_region
  image_name          = var.image_name
  skip_docker_build   = var.skip_docker_build
  image_tag_mutability = var.image_tag_mutability
  scan_on_push        = var.scan_on_push
  additional_tags     = local.common_tags
}

module "ecs" {
  source                       = "./modules/ecs"
  ecs_cluster_name             = var.ecs_cluster_name
  task_family                  = var.task_family
  task_role_arn                = var.task_role_arn
  cpu                          = var.cpu
  memory                       = var.memory
  container_name               = var.container_name
  container_image              = module.ecr.image_url
  container_port               = var.container_port
  desired_count                = var.desired_count
  public_subnet_ids            = module.vpc.public_subnet_ids
  ecs_security_group_id        = module.security_group.ecs_security_group_id
  blue_target_group_arn        = module.alb.blue_target_group_arn
  green_target_group_arn       = module.alb.green_target_group_arn
  ecs_task_definition          = var.ecs_task_definition
  execution_role_name          = var.execution_role_name
  blue_service_name            = var.blue_service_name
  green_service_name           = var.green_service_name
  environment                  = var.environment
  enable_container_insights    = var.enable_container_insights
  enable_container_logs        = var.enable_container_logs
  log_group_name               = var.log_group_name
  log_retention_days           = var.log_retention_days
  aws_region                   = var.aws_region
  container_environment        = var.container_environment
  deployment_maximum_percent   = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  health_check_grace_period_seconds = var.health_check_grace_period_seconds
  additional_tags              = local.common_tags

  depends_on = [module.alb, module.ecr]
}