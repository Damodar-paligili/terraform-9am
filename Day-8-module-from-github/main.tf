#create a vpc and two subnets in different availability zones and create a security group in the vpc and allow all traffic.create a subnet gropu for RDS and add both subnets to the subnet group.create a db instance in RDS and use the security group and subnet group created above.use variables to fetch the configuration using variable.tf file and dont hardcode the configuration in the main.tf file
variable "db_instance_class" {
  description = "The instance class for the RDS database"
  type        = string
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnett1_cidr
  availability_zone = var.availability_zone1
  tags = {
    Name = "main-subnet"
  }
}
resource "aws_subnet" "second" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnett2_cidr
  availability_zone = var.availability_zone2
  tags = {
    Name = "second-subnet"
  }
}
resource "aws_security_group" "main" {
  name        = "main-security-group"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
    }
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
    }
}
resource "aws_db_subnet_group" "main" {
  name       = var.db_subnet_group_name
    subnet_ids  = [aws_subnet.main.id, aws_subnet.second.id]
    tags = {
        Name = "main-subnet-group"
    }
}
resource "aws_db_instance" "main" {
    identifier = "main-db-instance"
  allocated_storage = 20
  engine = "mysql"
  engine_version = "8.0"
  instance_class = var.db_instance_class
  db_name = var.db_name
  username = var.db_username
  password = var.db_password
  backup_retention_period = 1
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.main.id]
  db_subnet_group_name = aws_db_subnet_group.main.name
}
