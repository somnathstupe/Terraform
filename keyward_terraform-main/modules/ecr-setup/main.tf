resource "aws_ecr_repository" "model_repository" {
  name                 = "${var.name_prefix}-keyward-images"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}