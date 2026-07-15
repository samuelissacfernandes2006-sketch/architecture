resource "aws_security_group" "dev_cluster" {
  name        = "${var.cluster_name}-sg"
  description = "Security group for dev cluster"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.allow_ssh ? [1] : []
    content {
      description = "Optional SSH access for development"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_allowed_cidrs
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.cluster_name}-sg"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}