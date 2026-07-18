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

variable "environment" {
  description = "Environment tag value"
  type        = string
  default     = "dev"
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

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block of the VPC where the security group will be created"
  type        = string
}

variable "cluster_name" {
  description = "Name prefix for dev cluster resources"
  type        = string
  default     = "dev-cluster"
}

variable "node_type" {
  description = "Type of the node"
  type        = string  
}