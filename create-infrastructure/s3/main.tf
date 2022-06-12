resource "aws_s3_bucket" "product-hunting-s3-bucket" {
  bucket = "product-hunting-terraform-state"

  tags = {
    Name        = "product-hunting-s3-bucket"
  }
}

resource "aws_s3_bucket_acl" "product-hunting-s3-bucket-acl" {
  bucket = aws_s3_bucket.product-hunting-s3-bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "product-hunting-s3-bucket-versioning" {
  bucket = aws_s3_bucket.product-hunting-s3-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
