output "cluster_enabled" {
  description = "Whether resources are enabled for creation"
  value       = var.enable_cluster
}

output "instance_ids" {
  description = "IDs of instances created in the dev cluster"
  value       = aws_instance.dev_node[*].id
}

output "private_ips" {
  description = "Private IPs of instances in the dev cluster"
  value       = aws_instance.dev_node[*].private_ip
}

output "public_ips" {
  description = "Public IPs of instances in the dev cluster"
  value       = aws_instance.dev_node[*].public_ip
}

output "security_group_id" {
  description = "Security group attached to dev nodes"
  value       = aws_security_group.dev_cluster.id
}

output "k3s_enabled" {
  description = "Whether k3s bootstrap is enabled"
  value       = var.enable_k3s
}
