output "instance_ids" {
	description = "IDs of the EC2 instances"
	value       = aws_instance.aws_instance[*].id
}

output "ssh_key_name" {
	description = "ssh_key_name for this ec2"
	value = aws_instance.aws_instance[*].key_name
}

output "public_ip" {
  description = "Public IPs of the EC2 instances"
  value       = aws_instance.aws_instance[*].public_ip
}

output "private_ip" {
	description = "Private IPs of the EC2 instances"
	value       = aws_instance.aws_instance[*].private_ip
}