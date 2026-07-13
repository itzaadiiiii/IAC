# variable.tf ----> locals.tf -----> main.tf
#This how we can use both variables + locals for creating the resources


# variable "vpc_id" {}
variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket to host the static website"
}
