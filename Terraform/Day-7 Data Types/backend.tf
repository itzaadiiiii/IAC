# Added S3 for Backend
terraform {
  backend "s3" {
    bucket       = "terraform-bucketttttt-2026"
    key          = "Terraform-State"
    region       = "us-east-1"
    use_lockfile = true
  }
}
