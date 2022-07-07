### Get current region

data "aws_region" "product-hunting-region" {
}

### Network resources

resource "aws_vpc" "product-hunting-vpc" {
  cidr_block           = "192.168.42.0/24"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "product-hunting-vpc"
  }
}

resource "aws_subnet" "product-hunting-subnet-public-1" {
  vpc_id                  = aws_vpc.product-hunting-vpc.id
  cidr_block              = "192.168.42.0/26"
  availability_zone       = "${data.aws_region.product-hunting-region.name}a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "product-hunting-subnet-public-1"
  }
}

resource "aws_subnet" "product-hunting-subnet-public-2" {
  vpc_id                  = aws_vpc.product-hunting-vpc.id
  cidr_block              = "192.168.42.64/26"
  availability_zone       = "${data.aws_region.product-hunting-region.name}b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "product-hunting-subnet-public-2"
  }
}

resource "aws_internet_gateway" "product-hunting-igw" {
  vpc_id = aws_vpc.product-hunting-vpc.id

  tags = {
    Name = "product-hunting-igw"
  }
}

resource "aws_route_table" "product-hunting-rtb-public" {
  vpc_id = aws_vpc.product-hunting-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.product-hunting-igw.id
  }

  tags = {
    Name = "product-hunting-rtb-public"
  }
}

resource "aws_route_table_association" "product-hunting-rtb-association-1" {
  subnet_id      = aws_subnet.product-hunting-subnet-public-1.id
  route_table_id = aws_route_table.product-hunting-rtb-public.id
}

resource "aws_route_table_association" "product-hunting-rtb-association-2" {
  subnet_id      = aws_subnet.product-hunting-subnet-public-2.id
  route_table_id = aws_route_table.product-hunting-rtb-public.id
}