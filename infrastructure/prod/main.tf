terraform {
  backend "s3" {
    bucket = "product-hunting-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "product-hunting-terraform-state-lock"
  }
}

data "aws_subnets" "product-hunting-aws-subnets" {
  filter {
    name   = "tag:Name"
    values = ["product-hunting-subnet-public-1", "product-hunting-subnet-public-2"]
  }
}

resource "aws_iam_role" "product-hunting-role-eks-cluster" {
  name = "product-hunting-role-eks-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "product-hunting-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.product-hunting-role-eks-cluster.name
}

resource "aws_iam_role_policy_attachment" "product-hunting-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.product-hunting-role-eks-cluster.name
}

resource "aws_eks_cluster" "product-hunting-eks-cluster" {
  name     = "product-hunting-eks-cluster"
  role_arn = aws_iam_role.product-hunting-role-eks-cluster.arn

  vpc_config {
    subnet_ids = [data.aws_subnets.product-hunting-aws-subnets.ids[0], data.aws_subnets.product-hunting-aws-subnets.ids[1]]
  }

  depends_on = [
    aws_iam_role_policy_attachment.product-hunting-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.product-hunting-AmazonEKSVPCResourceController,
  ]

  tags = {
    Name = "product-hunting-eks-cluster"
  }
}

resource "aws_iam_role" "product-hunting-role-eks-node-group" {
  name = "product-hunting-role-eks-node-group"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "product-hunting-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.product-hunting-role-eks-node-group.name
}

resource "aws_iam_role_policy_attachment" "product-hunting-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.product-hunting-role-eks-node-group.name
}

resource "aws_iam_role_policy_attachment" "product-hunting-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.product-hunting-role-eks-node-group.name
}

resource "aws_eks_node_group" "product-hunting-eks-node-group" {
  cluster_name    = aws_eks_cluster.product-hunting-eks-cluster.name
  node_group_name = "product-hunting-eks-node-group"
  node_role_arn   = aws_iam_role.product-hunting-role-eks-node-group.arn
  subnet_ids      = [data.aws_subnets.product-hunting-aws-subnets.ids[0], data.aws_subnets.product-hunting-aws-subnets.ids[1]]
  instance_types  = ["t2.micro"]

  scaling_config {
    desired_size = 3
    max_size     = 4
    min_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.product-hunting-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.product-hunting-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.product-hunting-AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = {
    Name = "product-hunting-eks-node-group"
  }
}
