### EKS resources

resource "aws_iam_role" "devops-role-eks-cluster" {
  name = "devops-role-eks-cluster"

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

resource "aws_iam_role_policy_attachment" "devops-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.devops-role-eks-cluster.name
}

resource "aws_iam_role_policy_attachment" "devops-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.devops-role-eks-cluster.name
}

resource "aws_eks_cluster" "devops-eks-cluster" {
  name     = "devops-eks-cluster"
  role_arn = aws_iam_role.devops-role-eks-cluster.arn

  vpc_config {
    subnet_ids = [aws_subnet.devops-subnet-public-1.id, aws_subnet.devops-subnet-public-2.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.devops-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.devops-AmazonEKSVPCResourceController,
  ]

  tags = {
    Name = "devops-eks-cluster"
  }
}

resource "aws_iam_role" "devops-role-eks-node-group" {
  name = "devops-role-eks-node-group"

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

resource "aws_iam_role_policy_attachment" "devops-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.devops-role-eks-node-group.name
}

resource "aws_iam_role_policy_attachment" "devops-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.devops-role-eks-node-group.name
}

resource "aws_iam_role_policy_attachment" "devops-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.devops-role-eks-node-group.name
}

resource "aws_eks_node_group" "devops-eks-node-group" {
  cluster_name    = aws_eks_cluster.devops-eks-cluster.name
  node_group_name = "devops-eks-node-group"
  node_role_arn   = aws_iam_role.devops-role-eks-node-group.arn
  subnet_ids      = [aws_subnet.devops-subnet-public-1.id, aws_subnet.devops-subnet-public-2.id]
  instance_types  = ["t2.micro"]

  scaling_config {
    desired_size = 3
    max_size     = 4
    min_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.devops-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.devops-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.devops-AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = {
    Name = "devops-eks-node-group"
  }
}
