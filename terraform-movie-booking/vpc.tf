resource "aws_vpc" "movie_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "movie-vpc"
  }
}