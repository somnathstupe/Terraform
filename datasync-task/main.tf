
# Service provider such aws,azure 
provider "aws" {
  }

# 1. Create s3 bucket 
resource "aws_s3_bucket" "tf-bucket" {
  bucket = "tf-bucket-ad"
}

resource "aws_s3_bucket_acl" "tf-bucket-a" {
  bucket = aws_s3_bucket.tf-bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioning_tf-bucket" {
  bucket = aws_s3_bucket.tf-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}


# 2.Create a custom vpc 
resource "aws_vpc" "first-vpc" {
    cidr_block = "10.0.0.0/16"
    
    tags = {
      name = "production"
    }

}
#  3.Internet gateway for vpc
resource "aws_internet_gateway" "gw" {
   vpc_id = aws_vpc.first-vpc.id

   tags = {
    name = "pro-gw"
   }
}

# 4.Creating a route table 

resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.first-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "pro"
  }
}

# 5.create a subnet within specific vpc
resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.first-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "prod-subnet"
  }
}

# 6. Subnets assoiation to route table
 
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}

# 7. Create security group and specify inbound and outbound traffic
resource "aws_security_group" "allow_web" {
  name        = "allow_web-traffic"
  description = "Allow  inbound traffic"
  vpc_id      = aws_vpc.first-vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

ingress{
    description = "inbound traffic"
    from_port        = 2049
    to_port          = 2049
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# 7. Create efs  file sytem 
resource "aws_efs_file_system" "tf-efs" {
    creation_token = "efs"
    performance_mode = "generalPurpose"
    throughput_mode="bursting"
    encrypted="true"
    tags={
         Name ="efs-ad"
    }
}
# 8. create datasync location for s3
resource "aws_datasync_location_s3" "source" {
  s3_bucket_arn = aws_s3_bucket.tf-bucket.arn
  subdirectory = "/"

  s3_config {
    #bucket_access_role_arn = aws_iam_role.some_role.arn
    bucket_access_role_arn = "arn:aws:iam::721767314185:role/service-role/AWSDataSyncS3BucketAccess-source-datas-bucket"
  }
}
  
# 9. Block all public access 
resource "aws_s3_bucket_public_access_block" "some_bucket_access" {
  bucket = aws_s3_bucket.tf-bucket.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
}
# 10. Hard code IAM role and policy  or use arn of already created role

# resource "aws_iam_policy" "bucket_policy" {
#   name        = "my-bucket-policy"
#   path        = "/"
#   description = "Allow "

#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Sid" : "VisualEditor0",
#         "Effect" : "Allow",
#         "Action" : [
#           "s3:PutObject",
#           "s3:GetObject",
#           "s3:ListBucket",
#           "s3:DeleteObject"
#         ],
#         "Resource" : [
#           "arn:aws:s3:::*/*",
#           "arn:aws:s3:::tf-bucket-ad"
#         ]
#       }
#     ]
#   })
# }

# resource "aws_iam_role" "some_role" {
#   name = "my_role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "s3.amazonaws.com"
#         }
#       },
#     ]
#   })
# }


# resource "aws_iam_role_policy_attachment" "some_bucket_policy" {
#   role       = aws_iam_role.some_role.name
#   #policy_arn = aws_iam_policy.bucket_policy.arn
#   #policy_arn ="arn:aws:iam::aws:policy/AWSDataSyncFullAccess"
# }

###############################################################################



# 11. create aws efs mouth target

resource "aws_efs_mount_target" "alpha" {
  file_system_id = aws_efs_file_system.tf-efs.id
  subnet_id      = aws_subnet.subnet-1.id
}

# 12 . create aws datasync location for efs

resource "aws_datasync_location_efs" "destination" {

  efs_file_system_arn = aws_efs_mount_target.alpha.file_system_arn

  ec2_config {
    security_group_arns = [aws_security_group.allow_web.arn]
    subnet_arn          = aws_subnet.subnet-1.arn
  }
  depends_on = [
    aws_efs_mount_target.alpha
  ]

}
# 13. Create a datasync task for  transfering data from s3 to efs

resource "aws_datasync_task" "data-task" {
  destination_location_arn = aws_datasync_location_efs.destination.arn 
  name                     = "tf-task"
  source_location_arn      = aws_datasync_location_s3.source.arn
  
}
