resource "aws_s3_bucket" "First_Bucket" {
  bucket = "aws-terraform-jan-2026-001"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}