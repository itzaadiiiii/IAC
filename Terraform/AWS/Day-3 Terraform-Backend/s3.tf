resource "aws_s3_bucket" "terraform_backend" {
  bucket = var.terraform_s3_bucket

  tags = {
    Name        = "${var.terraform_s3_bucket}"
    Environment = "Dev"
    Team        = "DevOps"
  Project = "Terraform" }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.terraform_backend.id
  versioning_configuration {
    status = "Enabled"
  }
}