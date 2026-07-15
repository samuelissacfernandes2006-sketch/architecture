provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_default_vpc" "dev" {}

resource "aws_default_subnet" "dev" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_security_group" "dev_cluster" {
  name        = "${var.cluster_name}-sg"
  description = "Security group for dev cluster"
  vpc_id      = aws_default_vpc.dev.id

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

resource "aws_instance" "dev_node" {
  count = var.enable_cluster ? var.instance_count : 0

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.ssh_key_name
  subnet_id              = aws_default_subnet.dev.id
  vpc_security_group_ids = [aws_security_group.dev_cluster.id]
  monitoring             = false

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_tokens = "required"
  }
  user_data = data.cloudinit_config.config_init.rendered 
  user_data_replace_on_change = true

  tags = {
    Name        = "${var.cluster_name}-node-${count.index + 1}"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
data "cloudinit_config" "config_init" {
  gzip          = false
  base64_encode = true

  part {
    filename     = "10-k3s-init.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/scripts/k3s-init.sh", {
      k3s_version  = var.k3s_version
      enable_k3s   = var.enable_k3s
      k3s_token    = var.k3s_token
      cluster_name = var.cluster_name
    })
  }

  part {
    filename     = "20-helm-install.sh"
    content_type = "text/x-shellscript"
    content = file("${path.module}/scripts/helm-install.sh")
  }

  part {
    filename     = "30-argocd-install.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/scripts/argocd-install.sh", {
      argocd_version   = var.argocd_version
      argocd_namespace = var.argocd_namespace
    })
  }
}
