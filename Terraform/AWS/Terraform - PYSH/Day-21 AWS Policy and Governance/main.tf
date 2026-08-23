resource "random_string" "bucket_suffix" {
    length  = 6
    special = false
    upper   = false
} 

# Create an S3 bucket for AWS Config to store configuration history and snapshots
resource "aws_s3_bucket" "config_bucket" {
    bucket = "${var.project_name}-config-bucket"
    acl    = "private

    tags = {
        Name        = "Terraform Config Bucket"
        Environment = "Governance"
        Managed_by  = "Terraform"
        Purpose     = "AWS-Config_Storeage"
    }
}


# Enable versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "config_bucket_versioning" {
    bucket = aws_s3_bucket.config_bucket.id         
    versioning_configuration {
        status = "Enabled"
    }
}
# Here you can use your costamized KMS key for encryption, but for simplicity, we are using the default S3 encryption.

# Enable encryption for the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "config_bucket_encryption" {
    bucket = aws_s3_bucket.config_bucket.id
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

# # Enable logging for the S3 bucket but you neet to create a another bucket for logging, so we are not enabling it here.
# resource "aws_s3_bucket_logging" "config_bucket_logging" {
#     bucket = aws_s3_bucket.config_bucket.id
#     target_bucket = aws_s3_bucket.config_bucket.id
#     target_prefix = "log/"
# }
# block bucket public access for the S3 bucket
resource "aws_s3_bucket_public_access_block" "config_bucket_public_access_block" {
    bucket = aws_s3_bucket.config_bucket.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

# Add bucket policy to block public access and allow only specific IAM roles to access the bucket
resource "aws_s3_bucket_policy" "config_bucket_policy" {
    bucket = aws_s3_bucket.config_bucket.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Deny"
                Principal = "*"
                Action = "s3:*"
                Resource = [
                    "${aws_s3_bucket.config_bucket.arn}/*",
                    aws_s3_bucket.config_bucket.arn
                ]
                Condition = {
                    Bool = {
                        "aws:SecureTransport" = "false"
                    }
                }
            },
            {
                Effect = "Allow"
                Principal = {
                    AWS = [
                        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.config_role_name}"
                    ]
                }
                Action = [
                    "s3:GetObject",
                    "s3:PutObject",
                    "s3:DeleteObject",
                    "s3:ListBucket"
                ]
                Resource = [
                    "${aws_s3_bucket.config_bucket.arn}/*",
                    aws_s3_bucket.config_bucket.arn
                ]
            }
        ]
    })
}