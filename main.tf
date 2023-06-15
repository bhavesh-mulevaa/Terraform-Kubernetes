provider "aws" {}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable ip_addr {} 
variable instance_type {}
resource "aws_vpc" "temp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "temp-subnet-1" {
    vpc_id = aws_vpc.temp-vpc.id
    cidr_block= var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name = "${var.env_prefix}-subnet"
    }
}

resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.temp-vpc.id
    tags = {
        Name = "${var.env_prefix}-i-gw"
    }
}

resource "aws_route_table" "temp-route-table" {
    vpc_id = aws_vpc.temp-vpc.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }
    tags = {
        Name = "${var.env_prefix}-route-table"
    }
}

resource "aws_route_table_association" "temp-rt-assoc" {
    subnet_id = aws_subnet.temp-subnet-1.id
    route_table_id = aws_route_table.temp-route-table.id
}

resource "aws_security_group" "temp-sg" {
    name = "${var.env_prefix}-sg"
    vpc_id = aws_vpc.temp-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.ip_addr]
    }
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/32"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/32"]
        prefix_list_ids = []
    }
    tags = {
        Name = "${var.env_prefix}-sg"
    }
}

data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true

    filter {
        name = "name"
        values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image.id
}

resource "aws_instance" "temp-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type

    subnet_id = aws_subnet.temp-subnet-1.id
    vpc_security_group_ids = [aws_security_group.temp-sg.id]

    associate_public_ip_address = true
    key_name = "GTM-Engine"
    tags = {
        Name = "${var.env_prefix}-server"
    }
}