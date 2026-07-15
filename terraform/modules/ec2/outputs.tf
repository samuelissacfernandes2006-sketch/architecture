output "instance_ids" {
	description = "IDs of the EC2 instances"
	value       = aws_instance.aws_instance[*].id
}
