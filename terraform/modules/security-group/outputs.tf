output "security_group_id" {
	description = "ID of the security group used by the cluster"
	value       = aws_security_group.dev_cluster.id
}
