output "cluster_ip"{
    value= aws_eks_cluster.my-eks.id
}

output "node_group_ip" {
    value = aws_eks_node_group.my-node-group.id
}
output "vpc_id"{
    value = aws_vpc.my-vpc.id
}
output "subnet_id"{
    value = aws_subnet.my-subnet[*].id
}