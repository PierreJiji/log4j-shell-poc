# CREATE ECR
resource "aws_ecr_repository" "ecr_repo" {
  name                 = "${local.name}-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}