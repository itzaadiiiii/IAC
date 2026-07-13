resource "aws_s3_bucket" "staticweb" {
  bucket = var.bucket_name

  tags = {
    Name        = "Static Website Bucket"
    Environment = "Dev"
  }
}


resource "aws_s3_bucket" "example" {
  bucket = "my-tf-example-bucket"
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.staticweb.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.staticweb.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.staticweb,
    aws_s3_bucket_public_access_block.staticweb,
  ]

  bucket = aws_s3_bucket.example.id
  acl    = "public-read"
}
