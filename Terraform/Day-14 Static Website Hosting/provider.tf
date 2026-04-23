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


#Add Provider
provider "aws" {
  region = "ap-south-1"
}
