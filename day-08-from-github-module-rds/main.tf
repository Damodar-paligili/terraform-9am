module "test" {
  source = "git::https://github.com/Damodar-paligili/terraform9am.git//Day-8-module-from-github"

  db_name              = "mydb"
  db_username          = "admin"
  db_password          = "password"
  db_subnet_group_name = "mydb-subnet-group"
  db_instance_class    = "db.t3.micro"
  vpc_cidr             = "10.0.0.0/16"
  subnett1_cidr         = "10.0.1.0/24"
  subnett2_cidr         = "10.0.2.0/24"
  availability_zone1   = "us-east-1a"
  availability_zone2   = "us-east-1b"
}