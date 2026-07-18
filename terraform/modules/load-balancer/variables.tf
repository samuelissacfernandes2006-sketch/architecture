variable "cluster_name" {
  description = "Name prefix for dev cluster resources"
  type        = string
  default     = "dev-cluster"
}

variable "node_type" {
  description = "Type of the node"
  type        = string  
}

variable "k3s_token" {
  description = "Optional k3s cluster token (leave null to auto-generate)"
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
}

variable "subnet_id" {
  description = "Subnet ID where the load balancer will be created"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the load balancer will be created"
  type        = string
}

variable "load_balancer_internal" {
  description = "If the load balancer is internal or not"
  type = bool
}

variable "environment" {
  description = "Environment tag value"
  type        = string
  default     = "dev"
}

variable "load_balancer_type" {
  description = "Load balancer type"
  type = string 
}