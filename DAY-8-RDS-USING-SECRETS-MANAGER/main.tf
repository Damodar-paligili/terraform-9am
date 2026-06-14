# create a vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
    tags = {
        Name = "main-vpc"
    }   
}
#create a subnet
resource "aws_subnet" "main" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
    tags = {
        Name = "main-subnet"
    }   
} 
# create second subnet
resource "aws_subnet" "second" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1b"
    tags = {
        Name = "second-subnet"
    }   
}
#create a subnet group
resource "aws_db_subnet_group" "main" {
  name = "main-subnet-group"
  subnet_ids = [aws_subnet.main.id, aws_subnet.second.id]
    tags = {
        Name = "main-subnet-group"
    }   
}
# create a security group
resource "aws_security_group" "main" {
  name = "main-security-group"
  description = "Allow access to RDS"
  vpc_id = aws_vpc.main.id
    tags = {
        Name = "main-security-group"
    }  
    ingress {
        from_port = 3306
        to_port = 3306
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
# create a rds instance .manage the password using secrets manager
resource "aws_db_instance" "main" {
  identifier = "main-db-instance"
  allocated_storage = 20
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  db_name = "maindb"
  username = "admin"
  password = "Admin1234"
  #manage_master_user_password = true
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.main.id]
  backup_retention_period = 1
    tags = {
        Name = "main-db-instance"
    }   
} 
