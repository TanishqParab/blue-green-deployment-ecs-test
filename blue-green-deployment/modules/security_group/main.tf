############################################
# Security Group Resources
############################################

resource "aws_security_group" "ecs_sg" {
  vpc_id      = var.vpc_id
  name        = var.security_group_name
  description = var.security_group_description

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = lookup(ingress.value, "description", null)
    }
  }

  egress {
    from_port   = var.egress_from_port
    to_port     = var.egress_to_port
    protocol    = var.egress_protocol
    cidr_blocks = var.egress_cidr_blocks
  }

  tags = merge(
    {
      Name = var.security_group_name
    },
    var.additional_tags
  )
}