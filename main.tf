# Provider block specifying Terraform Cloud as our remote backend. 
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}











