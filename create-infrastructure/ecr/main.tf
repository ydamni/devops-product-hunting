resource "aws_ecr_repository" "product-hunting-ecr-repository-postgres" {
  name                 = "product-hunting-postgres"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "product-hunting-ecr-repository-postgres"
  }
}

resource "aws_ecr_repository" "product-hunting-ecr-repository-api" {
  name                 = "product-hunting-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "product-hunting-ecr-repository-api"
  }
}

resource "aws_ecr_repository" "product-hunting-ecr-repository-client" {
  name                 = "product-hunting-client"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "product-hunting-ecr-repository-client"
  }
}
