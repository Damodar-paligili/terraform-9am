resource "aws_vpc" "name" {
    cidr_block = "10.0.0.0/24"
    tags = {
        Name = "Terraform-1100AM"
    }
  
}

resource "aws_subnet" "name" {
    vpc_id     = aws_vpc.name.id
    cidr_block = "10.0.0.0/26"
    tags = {
        Name = "Terraform-0900AM"
    }
}


