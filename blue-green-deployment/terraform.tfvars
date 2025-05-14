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
  # Basic VPC settings
  cidr_block           = "10.0.0.0/16"
  name                 = "Main VPC"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  
  # Subnet configuration
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
  subnet_name_prefix   = "Public-Subnet"
  map_public_ip_on_launch = true
  
  # Private subnet configuration (optional)
  create_private_subnets = false  # Set to true to enable private subnets
  private_subnet_cidrs   = []
  private_subnet_name_prefix = "Private-Subnet"
  create_nat_gateway     = false  # Set to true to enable NAT gateway
  
  # Routing configuration
  igw_name                = "Main-IGW"
  route_table_name        = "Public-RT"
  internet_cidr_block     = "0.0.0.0/0"
  route_creation_timeout  = "5m"
  
  # Flow logs (optional)
  enable_flow_logs       = false  # Set to true to enable flow logs
  flow_logs_traffic_type = "ALL"
  flow_logs_destination  = ""
  flow_logs_iam_role_arn = ""
  
  # Naming conventions
  nat_eip_name_suffix    = "nat-eip"
  nat_gateway_name_suffix = "nat-gateway"
  private_route_table_name_suffix = "private-rt"
  flow_logs_name_suffix  = "flow-logs"
  
  # Type tags
  public_subnet_type     = "Public"
  private_subnet_type    = "Private"
  public_route_table_type = "Public"
  private_route_table_type = "Private"
  
  # Calculation methods
  az_count_calculation_method = "min"
  
  # Tag settings
  module_name            = "vpc"
  terraform_managed      = "true"
}

# Security Group Configuration
security_group = {
  name        = "ECS Security Group"
  description = "Security group for ECS tasks"
  
  # Ingress rules
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
  
  # Egress rules
  egress_from_port   = 0
  egress_to_port     = 0
  egress_protocol    = "-1"
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_description = "Allow all outbound traffic"
  
  # Tag settings
  module_name        = "security_group"
  terraform_managed  = "true"
}

# ALB Configuration
alb = {
  # Basic ALB settings
  name                  = "blue-green-alb"
  internal              = false
  load_balancer_type    = "application"
  
  # Listener settings
  listener_port         = 80
  listener_protocol     = "HTTP"
  
  # Target group settings
  blue_target_group_name = "blue-tg"
  green_target_group_name = "green-tg"
  target_group_port     = 5000
  target_group_protocol = "HTTP"
  target_type           = "ip"
  deregistration_delay  = 300
  
  # Health check settings
  health_check_path     = "/health"
  health_check_interval = 30
  health_check_timeout  = 10
  healthy_threshold     = 3
  unhealthy_threshold   = 2
  health_check_matcher  = "200"
  health_check_port     = "traffic-port"
  health_check_protocol = "HTTP"
  
  # Stickiness settings
  stickiness_enabled    = true
  stickiness_duration   = 300
  target_group_stickiness_enabled = false
  target_group_stickiness_type = "lb_cookie"
  target_group_stickiness_duration = 86400
  
  # Traffic distribution
  blue_weight           = 100
  green_weight          = 0
  
  # HTTPS settings
  create_https_listener = false
  https_port            = 443
  https_protocol        = "HTTPS"
  ssl_policy            = "ELBSecurityPolicy-2016-08"
  certificate_arn       = ""
  
  # Access logs settings
  enable_access_logs    = false
  access_logs_bucket    = ""
  access_logs_prefix    = "alb-logs"
  access_logs_enabled   = true
  
  # Additional settings
  idle_timeout          = 60
  enable_deletion_protection = false
  drop_invalid_header_fields = false
  forward_action_type   = "forward"
  
  # Tag settings
  module_name           = "alb"
  terraform_managed     = "true"
  blue_deployment_group = "blue"
  green_deployment_group = "green"
}

# ECR Configuration
ecr = {
  # Basic ECR settings
  repository_name      = "blue-green-app"
  image_name           = "blue-green-app"
  skip_docker_build    = false
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
  
  # Docker build settings
  image_tag            = "latest"
  docker_username      = "AWS"
  docker_build_args    = ""
  
  # Retry settings
  max_retries          = 10
  retry_sleep_seconds  = 5
  
  # Error handling
  file_not_found_message = "file-not-found"
  always_run_trigger    = "timestamp()"
  
  # Tag settings
  module_name          = "ecr"
  terraform_managed    = "true"
}

# ECS Configuration
ecs = {
  # Basic ECS settings
  cluster_name        = "blue-green-cluster"
  task_family         = "blue-green-task"
  task_role_arn       = null # Will be created by the ECS module
  cpu                 = "256"
  memory              = "512"
  container_name      = "blue-green-container"
  container_port      = 80
  desired_count       = 1
  execution_role_name = "ecs-task-execution-role"
  blue_service_name   = "blue-service"
  green_service_name  = "green-service"
  task_definition     = "blue-green-task-def"

  # Container configurations
  enable_container_insights          = false
  enable_container_logs              = false
  log_group_name                     = "/ecs/blue-green-app"
  log_retention_days                 = 30
  container_environment              = []
  container_protocol                 = "tcp"
  blue_log_stream_prefix             = "blue"
  green_log_stream_prefix            = "green"
  container_essential                = true
  log_driver                         = "awslogs"
  
  # Deployment configurations
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds  = 60
  network_mode                       = "awsvpc"
  requires_compatibilities           = ["FARGATE"]
  launch_type                        = "FARGATE"
  assign_public_ip                   = true
  green_desired_count                = 0
  
  # Fargate configurations
  enable_fargate_capacity_providers  = false
  execute_command_logging            = "DEFAULT"
  capacity_provider_strategy         = [
    {
      capacity_provider = "FARGATE"
      weight            = 1
    }
  ]
  
  # IAM configurations
  logs_policy_name                   = "ecs-logs-policy"
  iam_policy_version                 = "2012-10-17"
  iam_service_principal              = "ecs-tasks.amazonaws.com"
  task_execution_policy_arn          = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  
  # Naming conventions
  green_container_name_suffix        = "-green"
  green_task_family_suffix           = "-green"
  blue_task_name_suffix              = "-blue"
  green_task_name_suffix             = "-green"
  log_resource_suffix                = ":*"
  
  # EFS configurations
  efs_root_directory_default         = "/"
  efs_transit_encryption_default     = "ENABLED"
  
  # Tag settings
  module_name                        = "ecs"
  terraform_managed                  = "true"
  blue_deployment_type               = "blue"
  green_deployment_type              = "green"
  blue_service_tag_name              = "Blue Service"
  green_service_tag_name             = "Green Service"
  
  # Optional configurations
  container_secrets                  = []
  task_volumes                       = []
}

# Pipeline Integration
pipeline = {
  blue_target_group_arn  = null
  green_target_group_arn = null
}