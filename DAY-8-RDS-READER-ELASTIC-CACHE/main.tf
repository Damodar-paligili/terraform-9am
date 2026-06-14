# data source to create a reader instance of RDS
data "aws_db_instance" "main" {
  db_instance_identifier = "main-db-instance"
}
#data source to get the security group of the main instance
data "aws_security_group" "main" {
  filter {
    name = "tag:Name"
    values = ["main-security-group"]
  }   
}
#data source to get the subnet group of the main instance
data "aws_db_subnet_group" "main" {
  name = "main-subnet-group"
}
# create a reader instance of db instance with backup retention period of 1 day use the same configuration as the main instance but dont hardcode the configuration use the data source to get the configuration of the main instance
resource "aws_db_instance" "reader" {
  identifier = "reader-db-instance"
  replicate_source_db = data.aws_db_instance.main.id
  vpc_security_group_ids = [data.aws_security_group.main.id]
  engine = data.aws_db_instance.main.engine
  engine_version = data.aws_db_instance.main.engine_version
  instance_class = "db.t3.micro"
  backup_retention_period = 1
  skip_final_snapshot = true
}
#data source to create a subnet group for elastic cache .use both subnets to create the subnet group
data "aws_subnet" "main" {
  filter {
    name = "tag:Name"
    values = ["main-subnet"]
  }   
}
data "aws_subnet" "second" {
  filter {
    name = "tag:Name"
    values = ["second-subnet"]
  }
}
resource "aws_elasticache_subnet_group" "main" {
  name = "main-elasticache-subnet-group"
  subnet_ids = [data.aws_subnet.main.id, data.aws_subnet.second.id]
    tags = {
        Name = "main-elasticache-subnet-group"
    }   
}
# create a elastic cache cluster
resource "aws_elasticache_cluster" "main" {
  cluster_id = "main-elasticache-cluster"
  engine = "redis"
  node_type = "cache.t3.micro"
  num_cache_nodes = 1
  subnet_group_name = aws_elasticache_subnet_group.main.name
    tags = {
        Name = "main-elasticache-cluster"
    }   
}
