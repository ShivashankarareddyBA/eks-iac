output "cluster_ip"{
    value= aws_eks_cluster.my_eks.id
}

output "node_group_ip" {
    value = aws_eks_node_group.my_node_group.id
}
output "vpc_id"{
    value = aws_vpc.my_vpc.id
}
output "subnet_id"{
    value = aws_subnet.my_subnet[*].id
}