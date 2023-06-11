provider "aws" {}

# variable "vpc_cidr_block" {
#     description = "VPC cidr block range"
# }

# variable "subnet_cidr_block" {
#     description = "Subnet cidr block"
# }

resource "aws_vpc" "temp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name="temp-dev"
    }
}

resource "aws_subnet" "temp-subnet-1" {
    vpc_id = aws_vpc.temp-vpc.id
    cidr_block= var.subnet_cidr_block
    availability_zone = "ap-south-1a"

    tags = {
        Name="temp-subnet"
    }
}

# resource "aws_ec2" "GTM" {

# }