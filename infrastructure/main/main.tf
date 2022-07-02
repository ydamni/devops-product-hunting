terraform {
  backend "s3" {
    bucket = "product-hunting-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "product-hunting-terraform-state-lock"
  }
}

module "ecr" {
  source = "./ecr"
}

module "vpc" {
  source = "./vpc"

  my_ip = var.my_ip
}

module "eks" {
  source = "./eks"

  product-hunting-subnet-public-1-id = module.vpc.subnet-public-1-id
  product-hunting-subnet-public-2-id = module.vpc.subnet-public-2-id
}
