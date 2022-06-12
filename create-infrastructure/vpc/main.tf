### Network resources

resource "aws_vpc" "devops-vpc" {
  cidr_block           = "192.168.42.0/24"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "devops-vpc"
  }
}

resource "aws_subnet" "devops-subnet-public-1" {
  vpc_id                  = aws_vpc.devops-vpc.id
  cidr_block              = "192.168.42.0/26"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "devops-subnet-public-1"
  }
}

resource "aws_subnet" "devops-subnet-public-2" {
  vpc_id                  = aws_vpc.devops-vpc.id
  cidr_block              = "192.168.42.64/26"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "devops-subnet-public-2"
  }
}

resource "aws_internet_gateway" "devops-igw" {
  vpc_id = aws_vpc.devops-vpc.id

  tags = {
    Name = "devops-igw"
  }
}

resource "aws_route_table" "devops-rtb-public" {
  vpc_id = aws_vpc.devops-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops-igw.id
  }

  tags = {
    Name = "devops-rtb-public"
  }
}

resource "aws_route_table_association" "devops-rtb-association-1" {
  subnet_id      = aws_subnet.devops-subnet-public-1.id
  route_table_id = aws_route_table.devops-rtb-public.id
}

resource "aws_route_table_association" "devops-rtb-association-2" {
  subnet_id      = aws_subnet.devops-subnet-public-2.id
  route_table_id = aws_route_table.devops-rtb-public.id
}

resource "aws_security_group" "devops-sg-allow-http" {
  name   = "devops-sg-allow-http"
  vpc_id = aws_vpc.devops-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-sg-allow-http"
  }
}
