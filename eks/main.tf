provider "aws"{
    region = "ap-south-1"
}
# VPC
resource "aws_vpc" "my-vpc"{
    cidr_block = "10.0.0.0/16"

    tags ={
        Name = "my-vpc"
    }
}
# subnets

resource "aws_subnet" "my-subnet" {
    count = 2
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = cidrsubnet(aws_vpc.my-vpc.cidr_block, 8, count.index)
    availability_zone = element(["ap-south-1a", "ap-south-1b"], count.index)
   map_public_ip_on_launch = true

   tags={
    Name = "my-subnet"
   }

}