
provider "aws" {
  
}

module "vpc" {
  #source = "terraform-aws-modules/vpc/aws"
  source ="C:/Users/ADMIN/Desktop/terraform_projects/keyward_terraform-main/modules/aws-web-server-vpc"

  #name = "main"
  #cidr = "10.0.0.0/16"

  #azs             = ["ap-south-1a", "ap-south-1b"]
  #private_subnets = ["10.0.1.0/24"]
  #public_subnets  = ["10.0.0.0/24"]

  #enable_nat_gateway = true

  #tags = {
   # Environment = "staging"
  #}
}


resource "aws_security_group" "sg-1" {
    vpc_id = module.vpc.vpc_id
    name = "tf-sg"
    description = " for http and ssh  " 
   
    ingress {
        description = "TLS from VPC"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/26"]
    }

   egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "allow_tls"
    }
}
