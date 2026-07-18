terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3"
    }
  }

  required_version = ">= 1.2"
}
provider "aws" {
  # region  = var.aws_region
  # profile = var.aws_profile

  # assume_role {
  #   role_arn     = "arn:aws:iam::199865934353:role/terraform"
  #   session_name = "terraform"
  #   external_id  = "terraform"
  # }
}