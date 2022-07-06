terraform {
  backend "s3" {
    bucket         = "product-hunting-terraform-state"
    key            = "main/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "product-hunting-terraform-state-lock"
  }
}

module "ecr" {
  source = "./ecr"
}

module "vpc" {
  source = "./vpc"
}
