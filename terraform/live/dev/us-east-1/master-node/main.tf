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

data "aws_vpc" "dev" {
  id = aws_default_vpc.dev.id
}

resource "aws_default_vpc" "dev" {}

resource "aws_default_subnet" "dev" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

module "security_group" {
  source = "../../../../modules/security-group"

  node_type = var.node_type
  aws_region        = var.aws_region
  aws_profile       = var.aws_profile
  cluster_name      = var.cluster_name
  allow_ssh         = var.allow_ssh
  ssh_allowed_cidrs = var.ssh_allowed_cidrs
  vpc_id            = aws_default_vpc.dev.id
  vpc_cidr_block    = data.aws_vpc.dev.cidr_block
}

module "load_balancer" {
  source = "../../../../modules/load-balancer"
  
  node_type              = var.node_type
  cluster_name           = var.cluster_name
  environment            = var.environment
  load_balancer_internal = var.load_balancer_internal
  load_balancer_type     = var.load_balancer_type
  subnet_id              = aws_default_subnet.dev.id
  vpc_id                 = aws_default_vpc.dev.id
}

module "aws_instance" {
  source = "../../../../modules/ec2"

  node_type = var.node_type
  aws_region             = var.aws_region
  aws_profile            = var.aws_profile
  cluster_name           = var.cluster_name
  environment            = var.environment
  instance_count         = var.instance_count
  instance_type          = var.instance_type
  allow_ssh              = var.allow_ssh
  ssh_allowed_cidrs      = var.ssh_allowed_cidrs
  ssh_key_name           = var.ssh_key_name
  enable_k3s             = var.enable_k3s
  k3s_version            = var.k3s_version
  k3s_token              = var.k3s_token
  argocd_version         = var.argocd_version
  argocd_namespace       = var.argocd_namespace
  ami_id                 = data.aws_ami.ubuntu.id
  subnet_id              = aws_default_subnet.dev.id
  vpc_security_group_ids = [module.security_group.security_group_id]
  user_data              = data.cloudinit_config.config_init.rendered
}

resource "aws_lb_target_group_attachment" "master_nodes" {
  count            = var.instance_count
  target_group_arn = module.load_balancer.target_group_arn
  target_id        = module.aws_instance.instance_ids[count.index]
  port             = 6443
}

data "cloudinit_config" "config_init" {
  gzip          = false
  base64_encode = true

  part {
    filename     = "k3s-init-master.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/../../../../scripts/k3s-init-master.sh", {
      enable_k3s        = true
      k3s_version       = var.k3s_version
      k3s_token         = var.k3s_token
      cluster_name      = var.cluster_name
      load_balancer_dns = module.load_balancer.dns_name
    })
  }
}
