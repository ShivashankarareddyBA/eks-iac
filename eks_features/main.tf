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
