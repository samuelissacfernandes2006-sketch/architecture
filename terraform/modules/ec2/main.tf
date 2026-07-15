resource "aws_instance" "aws_instance" {
  count                  = var.instance_count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.ssh_key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
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
  user_data = var.user_data
  user_data_replace_on_change = true

  tags = {
    Name        = "${var.cluster_name}-node-${count.index + 1}"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}