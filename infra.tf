provider "aws" {
  region  = "ap-south-1"
}

# Create VPC
resource "aws_vpc" "tfVPC" {
  cidr_block = "10.0.0.0/16"
}

# Create Internet Gateway
resource "aws_internet_gateway" "tfIG" {
  vpc_id = aws_vpc.tfVPC.id
}

# Create subnet
resource "aws_subnet" "tfSubnet" {
  vpc_id            = aws_vpc.tfVPC.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1b"
}

# Create Route Table
resource "aws_route_table" "tfRouteT" {
  vpc_id = aws_vpc.tfVPC.id
}

# Associate Internet Gateway with the Route Table
resource "aws_route" "tfRoute" {
  route_table_id         = aws_route_table.tfRouteT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.tfIG.id
}

# Associate Route Table with the Subnet
resource "aws_route_table_association" "tfRouteT-A" {
  subnet_id     = aws_subnet.tfSubnet.id
  route_table_id = aws_route_table.tfRouteT.id
}

# Create a security group
resource "aws_security_group" "tfSG" {
  vpc_id = aws_vpc.tfVPC.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }  
}

# Create EC2
resource "aws_instance" "myEC2" {

  ami           = "ami-xxxxxxxxxxxxxxxxxx"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.tfSubnet.id
  security_groups = [aws_security_group.tfSG.id]
  key_name      = "server"
  associate_public_ip_address = true

  tags = {
    Name = "MyEC2"
  }
}

