resource "aws_ecr_repository" "product-hunting-ecr-repository" {
  name                 = "product-hunting"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "product-hunting-ecr-repository"
  }
}
