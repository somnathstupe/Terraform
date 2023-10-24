terraform {
  backend "s3" {
    bucket       = "keyward-tf-backend"
    region       = "eu-west-1"
    key          = "al/tf-state.tfstate"
  }
}


provider "aws" {
  region     = "eu-west-1"
  
}

module "aws_web_server_vpc" {
  source = "./modules/aws-web-server-vpc"
}

module "ecr-setup" {
  source = "./modules/ecr-setup"

  tags                  = local.tags
  name_prefix             = local.name_prefix
  environment             = local.environment

}

module "compute-setup" {
  source = "./modules/compute-setup"

  tags                  = local.tags
  name_prefix             = local.name_prefix
  environment             = local.environment
  subnet_id               = "${module.aws_web_server_vpc.vpc_id}" 
  vpc_id                  = "${module.aws_web_server_vpc.vpc_id}"

}



