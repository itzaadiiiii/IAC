# Added S3 for Backend
terraform {
    backend "s3" {
        # bucket       = var.tf_backend_bucket
        bucket = "terraform-buckettttttttt"
        key          = "Terraform-State"
        region       = "ap-south-1"   #Mumbai
        use_lockfile = true
    }
}
