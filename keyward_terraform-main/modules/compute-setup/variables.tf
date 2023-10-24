variable tags{}
variable  name_prefix{}
variable  environment{}
# variable vpc_id{}
variable "vpc_id" {
  description = "VPC id for web server EC2 instance"
  type        = string
}

variable "subnet_id" {
  description = "Subnet id for web server EC2 instance"
  type        = string
}

