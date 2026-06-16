#############################################
# Provider
#############################################

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" 

}


#############################################
# VPC
#############################################

resource "aws_vpc" "main" {

  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "lambda-rds-vpc"
  }
}

#############################################
# Private Subnet 1
#############################################

resource "aws_subnet" "private_1" {

  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet-1"
  }
}

#############################################
# Private Subnet 2
#############################################

resource "aws_subnet" "private_2" {

  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-subnet-2"
  }
}

#############################################
# Lambda Security Group
#############################################

resource "aws_security_group" "lambda_sg" {

  name        = "lambda-sg"
  description = "Security Group for Lambda"
  vpc_id      = aws_vpc.main.id

  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "lambda-sg"
  }

}

#############################################
# RDS Security Group
#############################################

resource "aws_security_group" "rds_sg" {

  name        = "rds-sg"
  description = "Security Group for RDS"
  vpc_id      = aws_vpc.main.id

  ingress {

    description     = "MySQL from Lambda"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]

  }

  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "rds-sg"
  }

}

#############################################
# VPC Endpoint Security Group
#############################################

resource "aws_security_group" "vpce_sg" {

  name        = "vpce-sg"
  description = "Security Group for Interface Endpoint"
  vpc_id      = aws_vpc.main.id

  ingress {

    description     = "HTTPS from Lambda"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]

  }

  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "vpce-sg"
  }

}

#############################################
# DB Subnet Group
#############################################

resource "aws_db_subnet_group" "main" {

  name = "mysql-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]

  tags = {
    Name = "mysql-db-subnet-group"
  }

}

#############################################
# RDS MySQL
#############################################

resource "aws_db_instance" "mysql" {

  identifier = "terraform-mysql-db"

  engine         = "mysql"
  engine_version = "8.0"

  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type       = "gp3"
  storage_encrypted  = true

  db_name  = "employee_db"
  username = "admin"

  manage_master_user_password = true

  port = 3306

  publicly_accessible = false

  multi_az = false

  db_subnet_group_name = aws_db_subnet_group.main.name

  vpc_security_group_ids = [
    aws_security_group.rds_sg.id
  ]

  skip_final_snapshot = true

  deletion_protection = false

  backup_retention_period = 1

  tags = {
    Name = "terraform-mysql-db"
  }

}

#############################################
# Outputs
#############################################

output "rds_endpoint" {

  value = aws_db_instance.mysql.endpoint

}

output "secret_arn" {

  value = aws_db_instance.mysql.master_user_secret[0].secret_arn

}

#############################################
# Interface VPC Endpoint - Secrets Manager
#############################################

resource "aws_vpc_endpoint" "secretsmanager" {

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.us-east-1.secretsmanager"
  vpc_endpoint_type   = "Interface"

  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]

  security_group_ids = [
    aws_security_group.vpce_sg.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "secretsmanager-vpce"
  }
}


#############################################
# IAM Role for Lambda
#############################################

resource "aws_iam_role" "lambda_role" {

  name = "lambda-rds-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

}

#############################################
# IAM Policy for Secrets Manager
#############################################

resource "aws_iam_policy" "secrets_policy" {

  name = "lambda-secrets-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "secretsmanager:GetSecretValue"
      ],
      Resource = "*"
    }]
  })

}

resource "aws_iam_policy" "lambda_vpc_policy" {

  name = "lambda-vpc-network-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ],
        Resource = "*"
      }
    ]
  })
}

#############################################
# Attach Policies
#############################################

resource "aws_iam_role_policy_attachment" "lambda_basic" {

  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"

}

resource "aws_iam_role_policy_attachment" "lambda_secrets" {

  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.secrets_policy.arn

}

resource "aws_iam_role_policy_attachment" "lambda_vpc_attach" {

  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_vpc_policy.arn
}


#############################################
# Lambda Layer - PyMySQL
#############################################

resource "aws_lambda_layer_version" "pymysql" {

  filename            = "pymysql-layer.zip"
  layer_name          = "pymysql-layer"
  compatible_runtimes = ["python3.14"]

}

#############################################
# Lambda Function
#############################################

resource "aws_lambda_function" "lambda" {

  function_name = "rds-secrets-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.14"

  filename         = "lambda.zip"
  source_code_hash  = filebase64sha256("lambda.zip")

  layers = [
    aws_lambda_layer_version.pymysql.arn
  ]

  timeout = 30

  vpc_config {
    subnet_ids = [
      aws_subnet.private_1.id,
      aws_subnet.private_2.id
    ]

    security_group_ids = [
      aws_security_group.lambda_sg.id
    ]
  }

  environment {
    variables = {
      SECRET_NAME = aws_db_instance.mysql.master_user_secret[0].secret_arn
      RDS_HOST    = aws_db_instance.mysql.address
    }
  }

  depends_on = [
    aws_db_instance.mysql
  ]

}




