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