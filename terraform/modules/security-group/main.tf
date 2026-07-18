resource "aws_security_group" "dev_cluster" {
  name        = "${var.cluster_name}-${var.node_type}-sg"
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

  ingress {
    description = "K3s API from cluster nodes"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "K3s API from the VPC"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    description = "Flannel VXLAN between cluster nodes"
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    self        = true
  }

  ingress {
    description = "Kubelet metrics/control from cluster nodes"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    self        = true
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