terraform {
    required_providers {
        aws = {
        source = "hashicorp/aws"
        # version = "~> 5.0"
        version = "6.27.0"
        }
    }
    required_version = ">= 1.14.0"
}

resourse "aws_s3_bucket" "config_bucket" {
    bucket = "${var.project_name}-backend=buckettt"
    acl    = "private"

    tags = {
        Name        = "Terraform Config Bucket"
        Environment = "Governance"
        Managed_by  = "Terraform"
        Purpose     = "AWS-Config_Storeage"
    }
}