data "aws_vpc" "keyward-vpc" {
  id = var.vpc_id
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.keyward-vpc.id]
  }

  tags = {
    Tier = "Private"
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.keyward-vpc.id]
  }
  

  tags = {
    Tier = "Public"
  }
}




resource "aws_iam_role" "sagemaker_s3_ecr" {
  name               = "sagemaker_s3_ecr_role" 

  assume_role_policy = <<EOF

  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "sagemaker.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

  inline_policy {
    name = "s3_ecr_sagemaker_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["s3:*","ecr:SetRepositoryPolicy","ecr:CompleteLayerUpload","ecr:BatchDeleteImage","ecr:UploadLayerPart","ecr:DeleteRepositoryPolicy","ecr:InitiateLayerUpload","ecr:DeleteRepository","ecr:PutImage"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}

resource "aws_security_group" "efs_sg" {
  name        = "${var.name_prefix}-efs-sg"
  description = "SG for the EFS"
  vpc_id      = var.vpc_id

  ingress {
    description      = "HTTPS traffic from EFS: allow"
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/16"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}



resource "aws_security_group" "nb_sg" {
  name        = "${var.name_prefix}-sagemaker-sg"
  description = "SG for the EFS"
  vpc_id      = var.vpc_id

  ingress {
    description      = "HTTPS traffic from EFS: allow"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}

resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "lc" {
  name      = "${var.environment}-sagemaker-lfc"
  on_start  = base64encode("scripts/mount_efs.sh")
}

resource "aws_efs_file_system" "efs" {
    creation_token = "${var.name_prefix}-efs"
    performance_mode = "generalPurpose"
    throughput_mode = "bursting"

    tags = var.tags
}

resource "aws_efs_mount_target" "efs-mt1" {
   file_system_id  = aws_efs_file_system.efs.id
   count = 1
   subnet_id = tolist(data.aws_subnets.private.ids)[count.index % length(data.aws_subnets.private.ids)]
   security_groups = [aws_security_group.efs_sg.id]
}


resource "aws_sagemaker_notebook_instance" "ni" {
    name          = "keyward-notebook-instance"
    role_arn      = aws_iam_role.sagemaker_s3_ecr.arn
    instance_type = "ml.t2.medium"
    count = 1
    subnet_id = tolist(data.aws_subnets.private.ids)[count.index % length(data.aws_subnets.private.ids)]
    security_groups = [aws_security_group.nb_sg.id]
    
    tags = var.tags
    
}

resource "aws_cloudwatch_metric_alarm" "keyward-alarm" {
  alarm_name                = "terraform-keyward-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ni"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ni cpu utilization"
  insufficient_data_actions = []
#   instance_id = module.compute-setup.sagemaker_notebook_instance_id
  dimensions = {
    instance_id = "sagemaker_notebook_instance_id[0]"
  }
}
