resource "aws_ecr_repository" "main" {
  name         = "${var.project_name}-ecr"

  image_scanning_configuration {
    scan_on_push = true
  }
}