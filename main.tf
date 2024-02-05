# Provider block specifying Terraform Cloud as our remote backend. 
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  cloud {
    organization = "Mitchlyon"
    workspaces {
      name = "tf-aws-ecs-app"
    }
  }
}









