provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = file("C:/Users/ADMIN/.ssh/id_ed25519.pub")
}

resource "aws_instance" "web" {
  ami           = "ami-0521cb2d60cfbb1a6"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.mykey.key_name

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("C:/Users/ADMIN/.ssh/id_ed25519")
    host        = self.public_ip
  }

 provisioner "remote-exec" {
  inline = [
    "sudo yum update -y",
    "sudo yum install nginx1 -y",
    "sudo systemctl start nginx",
    "sudo systemctl enable nginx",
    "sudo yum install git -y"
  ]
}
}