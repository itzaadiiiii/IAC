resource "aws_s3_bucket" "terraform_state" {
    bucket = "${var.project_name}-config-bucket"
    acl    = "private"

    versioning {
        enabled = true
    }

    server_side_encryption_configuration {
        rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
        }
    }

    tags = {
        Name        = "Terraform State Bucket"
        Environment = "Governance"
        Managed_by  = "Terraform"
        Purpose     = "AWS-Config_Storeage"
    }
}