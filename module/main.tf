# Provider block. Tells Terraform what language provider to use. 
provider "aws" {
  region = "us-east-1"
}

module "serverless" {
  
  # Points the module to where TF templates are living. "../" points to the root of the repo.
  source = "../"

  # Name used to identify resources, will be attached to everything. 
  name = "chucknorris"

  # VPC CIDR block
  cidr = "10.0.0.0/16"

  # Availability Zones into which Fargate containers will be deployed. Must have at least two. 
  azs = [
    "us-east-1a",
    "us-east-1b"
  ]

  # Public subnet CIDRs. The load balancer lives here.
  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  # Private subnet CIDRs. ECS containers live here. 
  private_subnets = [
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]

}
