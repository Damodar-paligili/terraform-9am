provider "aws" {
  
}
variable "security_groups" {
  type = map(string)

  default = {
    frontend = "0.0.0.0/0"
    backend  = "10.0.0.0/16"
    database = "172.16.0.0/16"
  }
}

resource "aws_security_group" "sg" {
  for_each = var.security_groups

  name = "${each.key}-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [each.value]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [each.value]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}