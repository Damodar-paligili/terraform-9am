provider "aws" {
  
}
variable "security_groups" {
  default = [
    "frontend-sg",
    "backend-sg",
    "database-sg"
  ]
}


resource "aws_security_group" "sg" {
  for_each = toset(var.security_groups)
  
  name        = each.value
  description = "Security Group for ${each.value}"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks =["10.0.0.0/16"]
  }


  tags = {
    Name = each.value
  }
}