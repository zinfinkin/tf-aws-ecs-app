terraform {
  cloud {
    organization = "Mitchlyon"

    workspaces {
      name = "tf-aws-ecs-app"
    }
  }
}