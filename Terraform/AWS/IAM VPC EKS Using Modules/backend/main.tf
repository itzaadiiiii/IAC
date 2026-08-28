terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "6.27.0"
        }
    }
    required_version = ">= 1.14.0"

    backend "s3" {
        bucket       = "${var.project_name}-backend-buckettt"
        key          = "Terraform-State"
        region       = "us-east-1"
        use_lockfile = true
    }
}

provider "aws" {
    region = "us-east-1"

    default_tags {
        tags = {
            Name        = "Terraform Config Bucket"
            Environment = "Governance"
            Managed_by  = "Terraform"
            Purpose     = "IAM VPC EKS"
        }
    }
}
