variable "vpc_cidr" {
    description = "The CIDR block for the VPC"
    type        = string
    default     = ""
  
}
variable "subnett1_cidr" {
    description = "The CIDR block for the first subnet"
    type        = string
    default     = ""
  
}
variable "subnett2_cidr" {
    description = "The CIDR block for the second subnet"
    type        = string
    default     = ""
  
}
variable "availability_zone1" {
    description = "The availability zone for the first subnet"
    type        = string
    default     = ""
  
}
variable "availability_zone2" {
    description = "The availability zone for the second subnet"
    type        = string
    default     = ""
  
}
variable "db_name" {
    description = "The name of the database"
    type        = string
    default     = ""
  
}
variable "db_username" {
    description = "The username for the database"
    type        = string
    default     = ""
  
}
variable "db_password" {
    description = "The password for the database"
    type        = string
    default     = ""
  
}
variable "db_subnet_group_name" {
    description = "The name of the subnet group for RDS"
    type        = string
    default     = ""
  
}