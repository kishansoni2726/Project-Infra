resource "aws_ecr_repository" "db-migration" {
    name  = "${var.project}-db-migration"
}

resource "aws_ecr_repository" "frontend" {
    name  = "${var.project}-frontend"
}

resource "aws_ecr_repository" "backend" {
    name  = "${var.project}-backend"
}