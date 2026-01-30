provider "aws" {
  region = "ap-south-1"
}

# VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "my-vpc"
  }
}

# Subnets
resource "aws_subnet" "my_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.my_vpc.cidr_block, 8, count.index)
  availability_zone       = element(["ap-south-1a", "ap-south-1b"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name                                      = "my-subnet-${count.index}"
    "kubernetes.io/role/elb"                  = "1"
    "kubernetes.io/cluster/my-eks-cluster"    = "shared"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-igw"
  }
}

# Route Table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "my-route-table"
  }
}

# Route Table Association
resource "aws_route_table_association" "my_rt_association" {
  count          = 2
  subnet_id      = aws_subnet.my_subnet[count.index].id
  route_table_id = aws_route_table.my_route_table.id
}

# EKS Cluster Security Group
resource "aws_security_group" "eks_cluster_sg" {
  name        = "eks-cluster-sg"
  description = "EKS cluster security group"
  vpc_id      = aws_vpc.my_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-cluster-sg"
  }
}

# EKS Worker Node Security Group
resource "aws_security_group" "eks_node_sg" {
  name        = "eks-node-sg"
  description = "EKS worker node security group"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.eks_cluster_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-node-sg"
  }
}

#IAM role- EKS-cluset

resource "aws_iam_role" "my_eks_cluster_role"{
    name =  "my_eks_cluster_role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "eks.amazonaws.com"
                }
            }
        ]
    })
     tags = {
    Name        = "my_eks-cluster-role"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
    resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
        role       = aws_iam_role.my_eks_cluster_role.name
        policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    }

# worker nodes IAM role 
resource "aws_iam_role" "my_eks_worker_node_role" {
    name = "my_eks_worker_node_role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })
     tags = {
    Name        = "my_eks-worker-node-role"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

    resource "aws_iam_role_policy_attachment" "eks_worker_node_AmazonEKSWorkerNodePolicy" {
        role       = aws_iam_role.my_eks_worker_node_role.name
        policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    }

    resource "aws_iam_role_policy_attachment" "eks_worker_node_AmazonEC2ContainerRegistryReadOnly" {
        role       = aws_iam_role.my_eks_worker_node_role.name
        policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    }

    resource "aws_iam_role_policy_attachment" "eks_worker_node_AmazonEKS_CNI_Policy" {
        role       = aws_iam_role.my_eks_worker_node_role.name
        policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    }
