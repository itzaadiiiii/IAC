terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # version = "~> 5.0"
      version = "6.27.0"
    }
  }
  required_version = ">= 1.14.0"

# Added S3 for Backend
  backend "s3" {
    bucket       = "terraform-bucketttttt-2026"
    key          = "Terraform-State"
    region       = "us-east-1"
    use_lockfile = true
  }
}

#Add Provider
provider "aws" {
  region = "us-east-1"
}
