#create a resource "aws instance" to launch an EC2 instance in AWS and fetch the values from variables.tf file
resource "aws_instance" "my_instance" {
  ami    = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = var.name
    }
}