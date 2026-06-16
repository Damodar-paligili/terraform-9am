provider "aws" {
  

}
variable "instance_names" {
  default = ["frontend", "database"]
}

resource "aws_instance" "web" {
  count = length(var.instance_names)

  ami           = "ami-0521cb2d60cfbb1a6"
  instance_type = "t2.micro"

  tags = {
    Name = var.instance_names[count.index]
  }
}