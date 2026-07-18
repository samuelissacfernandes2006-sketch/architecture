output "dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.aws_load_balancer.dns_name
}

output "target_group_arn" {
  description = "ARN of the k3s API target group"
  value       = aws_lb_target_group.k3s_api.arn
}
