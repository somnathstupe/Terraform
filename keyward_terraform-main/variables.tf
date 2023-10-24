variable "aws_region" {
  description = "AWS region"
  type        = string
}
variable "vpc_id" {
  description = "A feature flag for whether to use default vpc"
  type        = bool
  default     = true
  
}

variable tags {
  type = map(string)
  description = "tags to apply to the resources"
  default     = {
  createdBy   = "Terraform"
  owner       = "keyward"
  product     = "a1"
  # expDate     = "none"
  }
}

locals {
  environment = "${terraform.workspace}"
}

locals {
  tags = merge(var.tags, { "environment" = "${local.environment}" })
  name_prefix = "${lower(var.tags.owner)}-${lower(local.environment)}-${lower(var.tags.product)}"
}

