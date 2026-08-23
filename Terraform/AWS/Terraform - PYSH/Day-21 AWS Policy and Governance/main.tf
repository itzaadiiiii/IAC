resource "random_string" "bucket_suffix" {
    length  = 6
    special = false
    upper   = false
} 


resource "aws_s3_bucket" "config_bucket" {
    bucket = "${var.project_name}-config-bucket"
    acl    = "private"

    server_side_encryption_configuration {
        rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
        }
    }

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