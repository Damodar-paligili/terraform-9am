provider "aws" {
  region = "us-east-1"
}

variable "instances" {
  default = {
    frontend = "t3.micro"
    backend = "t3.micro"
  }
}

resource "aws_instance" "ec2" {
  for_each = var.instances

  ami           = "ami-0521cb2d60cfbb1a6" # Replace with your AMI ID
  instance_type = each.value

  tags = {
    Name = each.key
  }
}