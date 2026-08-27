terraform {
    backend "s3" {
        bucket = "terraform-buckettttttttt"
        key    = "Terraform-State"
        region = "ap-south-1"   #Mumbai
    }   
}
