resource "aws_vpc" "vpc-keyward" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "subnet-keyward" {
  vpc_id                  = aws_vpc.vpc-keyward.id
  cidr_block              = var.subnet_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = var.aws_az

  tags = {
    Name = var.subnet_name
    Tier = "Private"
  }
}

resource "aws_internet_gateway" "keyward-gateway" {
  vpc_id = aws_vpc.vpc-keyward.id

  tags = {
    Name = var.igw_name
  }
}