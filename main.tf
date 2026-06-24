

terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "My-Own-Vpc"
  }
}

resource "aws_subnet" "pubsub" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "My-Public-Subnet"
  }
}

resource "aws_subnet" "prisub" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1c"

  tags = {
    Name = "My-Private-Subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "My-IGW"
  }
}

resource "aws_route_table" "pubrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "My-Public-RT"
  }
}
resource "aws_route_table_association" "pubsubasso" {
  subnet_id      = aws_subnet.pubsub.id
  route_table_id = aws_route_table.pubrt.id
}

resource "aws_eip" "eip" {}

resource "aws_nat_gateway" "mynat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.pubsub.id

  tags = {
    Name = "My-NAT-GW"
  }
}

resource "aws_route_table" "prirt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.mynat.id
  }

  tags = {
    Name = "My-Private-RT"
  }
}
resource "aws_route_table_association" "prisubasso" {
  subnet_id      = aws_subnet.prisub.id
  route_table_id = aws_route_table.prirt.id
}

resource "aws_security_group" "pubsg" {
  name        = "pubsg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description = "TLS from vpc"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Public-SG"
  }
}

resource "aws_security_group" "prisg" {
  name        = "prisg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description = "TLS from vpc"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Private-SG"
  }
}

resource "aws_instance" "pub_instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  availability_zone           = "ap-south-1a"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.pubsg.id]
  subnet_id                   = aws_subnet.pubsub.id
  key_name                    = var.key_name

  tags = {
    Name = "Public-Server"
  }
}

resource "aws_instance" "pri_instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  availability_zone           = "ap-south-1c"
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.prisg.id]
  subnet_id                   = aws_subnet.prisub.id
  key_name                    = var.key_name

  tags = {
    Name = "Private-Server"
  }
}

