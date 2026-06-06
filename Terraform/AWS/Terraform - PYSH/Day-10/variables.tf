# variable.tf ----> locals.tf -----> main.tf     
#This how we can use both variables + locals for creating the resources
variable "terraform_s3_bucket" {
  description = "Terraform Backend Bucket Name"
  type        = string
}


# Input Variables
variable "company" {
  description = "Company Name"
  type        = string
  default     = "Stepstrong"
}

variable "env" {
  description = "Environment"
  type        = string
  default     = "dev"
}


