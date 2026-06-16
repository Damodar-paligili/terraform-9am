provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "demo" {
  ami           = "ami-0521cb2d60cfbb1a6"
  instance_type = "t3.micro"

  provisioner "local-exec" {
    command = "echo Instance created with IP: ${self.public_ip} >> instance-log.txt"
  }
}