resource "aws_lb" "aws_load_balancer" {
  name               = "${var.cluster_name}-lb"
  internal           = var.load_balancer_internal
  load_balancer_type = var.load_balancer_type
  subnets            = [var.subnet_id]

  enable_deletion_protection = false

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_lb_target_group" "k3s_api" {
  name        = "${var.cluster_name}-k3s-api"
  port        = 6443
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    protocol            = "TCP"
    port                = 6443
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "k3s_api" {
  load_balancer_arn = aws_lb.aws_load_balancer.arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k3s_api.arn
  }
}