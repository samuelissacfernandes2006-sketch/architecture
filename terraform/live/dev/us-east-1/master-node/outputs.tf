output "master_public_ip" {
  description = "Public IP of the k3s master node"
  value       = module.aws_instance.public_ip[0]
}

output "master_private_ip" {
  description = "Private IP of the k3s master node"
  value       = module.aws_instance.private_ip[0]
}

output "dns_name" {
  description = "DNS name of the load balancer"
  value       = module.load_balancer.dns_name
  }