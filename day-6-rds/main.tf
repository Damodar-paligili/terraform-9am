# creation of vpc
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my_vpc"
  } 
}

#creation of public subnet and private subnet in two different availability zones
resource "aws_subnet" "my_public_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true  
  availability_zone = "us-east-1a"  
    tags = {
        Name = "my_public_subnet"
    }   
}
#creation of puclic subnet in another availability zone
resource "aws_subnet" "my_public_subnet_2" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
    tags = {
        Name = "my_public_subnet_2"
    }   
}

resource "aws_subnet" "my_private_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "my_private_subnet"
  } 
}
#creation of internet gateway and attaching it to vpc
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my_igw"
  } 
}
#creation of route table and route to internet gateway
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my_route_table"
  } 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
    }
}
#association of route table with two public subnets
resource "aws_route_table_association" "my_route_table_association" {
  subnet_id = aws_subnet.my_public_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}
resource "aws_route_table_association" "my_route_table_association_2" {
  subnet_id = aws_subnet.my_public_subnet_2.id
  route_table_id = aws_route_table.my_route_table.id
} 

#creation of elastic ip for nat gateway
resource "aws_eip" "my_eip" {
    domain = "vpc"
    tags = {
        Name = "my_eip"
    }   
}
#creation of nat gateway in public subnet
resource "aws_nat_gateway" "my_nat_gateway" {
  subnet_id = aws_subnet.my_public_subnet.id
  allocation_id = aws_eip.my_eip.id
  tags = {
    Name = "my_nat_gateway"
  }
}   
#creation of private route table and route to nat gateway
resource "aws_route_table" "my_private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my_private_route_table"
  } 
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
    }
}
#association of private route table with private subnet 
resource "aws_route_table_association" "my_private_route_table_association" {
  subnet_id = aws_subnet.my_private_subnet.id
  route_table_id = aws_route_table.my_private_route_table.id
}
#creation of security group for public instances
resource "aws_security_group" "my_public_sg" {
  name = "my_public_sg"
  description = "security group for public instances"
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my_public_sg"
  } 
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
#creation of instance in public subnet and installing nginx web server using user data and starting and enabling nginx service
resource "aws_instance" "my_public_instance" {
  ami = "ami-00e801948462f718a"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.my_public_subnet.id
  vpc_security_group_ids = [aws_security_group.my_public_sg.id]
  tags = {
    Name = "my_public_instance"
  } 
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install nginx -y
              sudo systemctl start nginx
              sudo systemctl enable nginx
              EOF   
}   

#creation of target group for load balancer with public instance as target
resource "aws_lb_target_group" "my_target_group" {
  name = "my-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.my_vpc.id
  target_type = "instance"
  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200-399"
    interval = 30
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}
resource "aws_lb_target_group_attachment" "my_target_group_attachment" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id = aws_instance.my_public_instance.id
  port = 80
}
#creation of load balancer and listener
resource "aws_lb" "my_lb" {
  name = "my-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.my_public_sg.id]
  subnets = [aws_subnet.my_public_subnet.id, aws_subnet.my_public_subnet_2.id]
  tags = {
    Name = "my_lb"
  } 
}
resource "aws_lb_listener" "my_lb_listener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}       
