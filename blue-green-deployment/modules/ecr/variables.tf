variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "app_py_path" {
  description = "Path to the app.py file"
  type        = string
}

variable "dockerfile_path" {
  description = "Path to the Dockerfile"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
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

variable "max_retries" {
  description = "Maximum number of retries for ECR repository availability check"
  type        = number
  default     = 10
}

variable "retry_sleep_seconds" {
  description = "Number of seconds to sleep between retries"
  type        = number
  default     = 5
}

variable "additional_tags" {
  description = "Additional tags for ECR resources"
  type        = map(string)
  default     = {}
}