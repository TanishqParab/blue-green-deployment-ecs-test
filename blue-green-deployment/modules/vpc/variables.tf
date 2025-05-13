variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
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

variable "subnet_name_prefix" {
  description = "Prefix for subnet names"
  type        = string
  default     = "Public-Subnet"
}

variable "igw_name" {
  description = "Name of the Internet Gateway"
  type        = string
  default     = "Main-IGW"
}

variable "route_table_name" {
  description = "Name of the route table"
  type        = string
  default     = "Public-RT"
}

variable "map_public_ip_on_launch" {
  description = "Auto-assign public IP on launch for public subnets"
  type        = bool
  default     = true
}

variable "additional_tags" {
  description = "Additional tags for VPC resources"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"
  validation {
    condition     = contains(["default", "dedicated", "host"], var.instance_tenancy)
    error_message = "Instance tenancy must be one of: default, dedicated, or host."
  }
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

variable "private_subnet_name_prefix" {
  description = "Prefix for private subnet names"
  type        = string
  default     = "Private-Subnet"
}

variable "create_nat_gateway" {
  description = "Whether to create a NAT Gateway for private subnets"
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Whether to enable VPC Flow Logs"
  type        = bool
  default     = false
}

variable "flow_logs_destination" {
  description = "The ARN of the CloudWatch log group or S3 bucket where VPC Flow Logs will be published"
  type        = string
  default     = ""
}

variable "flow_logs_traffic_type" {
  description = "The type of traffic to capture (ACCEPT, REJECT, ALL)"
  type        = string
  default     = "ALL"
  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.flow_logs_traffic_type)
    error_message = "Flow logs traffic type must be one of: ACCEPT, REJECT, or ALL."
  }
}

variable "flow_logs_iam_role_arn" {
  description = "The ARN of the IAM role that allows Amazon EC2 to publish flow logs to CloudWatch Logs"
  type        = string
  default     = ""
}

