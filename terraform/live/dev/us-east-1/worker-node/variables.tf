variable "aws_region" {
  description = "AWS region for the dev cluster"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS shared profile name used by Terraform"
  type        = string
  default     = null
  nullable    = true
}

variable "cluster_name" {
  description = "Name prefix for dev cluster resources"
  type        = string
  default     = "dev-cluster"
}

variable "environment" {
  description = "Environment tag value"
  type        = string
  default     = "dev"
}

variable "instance_count" {
  description = "Number of EC2 instances in the dev cluster"
  type        = number
  default     = 1

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 2
    error_message = "For cost control, instance_count must be between 1 and 2."
  }
}

variable "instance_type" {
  description = "EC2 instance type (prefer free-tier eligible values)"
  type        = string
  default     = "t3.micro"
}

variable "allow_ssh" {
  description = "Whether to open SSH port 22"
  type        = bool
  default     = true
}

variable "ssh_allowed_cidrs" {
  description = "CIDR ranges allowed to access SSH when allow_ssh is true"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_key_name" {
  description = "AWS EC2 Key Pair name for SSH access"
  type        = string
  default     = null
  nullable    = true

}

variable "enable_k3s" {
  description = "Install and configure k3s during instance bootstrap"
  type        = bool
  default     = true
}

variable "k3s_version" {
  description = "k3s version channel or pinned release"
  type        = string
  default     = "v1.35.0+k3s3"
}

variable "k3s_token" {
  description = "Optional k3s cluster token (leave null to auto-generate)"
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
}

variable "argocd_version" {
  description = "argocd version release"
  type        = string
  default     = "10.1.2"
}

variable "argocd_namespace" {
  description = "argocd namespace on installation"
  type        = string
  default     = "argocd"
}



variable "node_type" {
  description = "Type of the node"
  type        = string  
  nullable = false
}

variable "master_nodes_dns" {
  description = "Load balancer DNS for master nodes" 
  type = string
  nullable = false
}