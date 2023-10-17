provider "aws" {
  region = var.aws_region
  profile = var.profile
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}