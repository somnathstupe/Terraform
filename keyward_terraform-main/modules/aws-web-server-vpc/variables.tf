variable "vpc_cidr_block" {
  description = "CIDR block for webserver VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name of the vpc"
  type        = string
  default     = "vpc-keyward"
}

variable "subnet_cidr_block" {
  description = "CIDR block for the webserver subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "subnet_name" {
  description = "Name for the webserver subnet"
  type        = string
  default     = "subnet-keywards"
}

variable "aws_az" {
  description = "Availability Zone for the keyward subnet"
  type        = string
  default     = "ap-south-1a"
}

variable "igw_name" {
  description = "Name for the Internet Gateway of the keyward vpc"
  type        = string
  default     = "keyward"
} 


variable "ign_name" {
  description ="the first commit for variable"
  type = string 
  default = "keyward"

}