############################################
# ECR Repository
############################################

resource "aws_ecr_repository" "app_repo" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = merge(
    {
      Name = var.repository_name
    },
    var.additional_tags
  )
}

############################################
# Docker Build and Push
############################################

resource "null_resource" "docker_build_push" {
  count = var.skip_docker_build ? 0 : 1

  triggers = {
    app_py_sha1        = fileexists(var.app_py_path) ? filesha1(var.app_py_path) : "file-not-found"
    dockerfile_sha1    = fileexists(var.dockerfile_path) ? filesha1(var.dockerfile_path) : "file-not-found"
    ecr_repository_url = aws_ecr_repository.app_repo.repository_url
    always_run         = timestamp() # This will cause it to run on every apply
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Authenticate Docker to ECR
      aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.app_repo.repository_url}
      
      # Navigate to the directory with Dockerfile
      cd ${dirname(var.dockerfile_path)}
      
      # Build the Docker image
      docker build -t ${var.image_name} .
      
      # Tag the image
      docker tag ${var.image_name}:latest ${aws_ecr_repository.app_repo.repository_url}:latest
      
      # Push the image
      docker push ${aws_ecr_repository.app_repo.repository_url}:latest
    EOT
  }

  depends_on = [aws_ecr_repository.app_repo]
}
