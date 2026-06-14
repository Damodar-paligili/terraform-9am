#creation of vpc
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my_vpc"
  }
}

# creation of subnet
resource "aws_subnet" "my_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "my_subnet"
  }
}   

#creation of private subnet
resource "aws_subnet" "my_private_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "my_private_subnet"
  }
}
#creation of internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my_igw"
  }
}

#creation of route table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my_route_table"
  }
  #route to internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }     
}
#association of route table with subnet
resource "aws_route_table_association" "my_route_table_association" {
  subnet_id = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}   

#creation of private route table
resource "aws_route_table" "my_private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my_private_route_table"
  }
}   
#association of private route table with private subnet
resource "aws_route_table_association" "my_private_route_table_association" {
  subnet_id = aws_subnet.my_private_subnet.id
  route_table_id = aws_route_table.my_private_route_table.id
}   
#creation of elastic ip for nat gateway
resource "aws_eip" "my_eip" {
  domain = "vpc"
}
#creation of nat gateway
resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_eip.id
  subnet_id = aws_subnet.my_subnet.id
  tags = {
    Name = "my_nat_gateway"
  }
}   
#route to nat gateway in private route table
resource "aws_route" "my_private_route" {
  route_table_id = aws_route_table.my_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
}
#creation of security group
resource "aws_security_group" "my_sg" {
  name = "my_sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my_sg"
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#creation of ec2 instance in public subnet
resource "aws_instance" "my_instance" {
  ami = "ami-00e801948462f718a" # Amazon Linux 2 AMI
  instance_type = "t3.micro"
  subnet_id = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  tags = {
    Name = "my_instance"
  }
}
