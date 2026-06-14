variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
  default = null
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default = null
}

variable "name" {
  description = "The name tag for the EC2 instance"
  type        = string
  default = null
}