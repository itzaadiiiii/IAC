variable "company" {
  description = "Company Name"
  type        = string
}

variable "environment" {
  description = "Environment Name"
  type        = string
}

locals {
  CompanyName = var.company
  Environment = var.environment
}

resource "aws_s3_bucket" "name" {
  bucket = "${local.CompanyName}-${local.Environment}-terraform-state"
}

