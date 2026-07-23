variable "primary" {
    default = "us-east-1"
}

variable "secondary" {
    type = string
    default = "us-west-2"
}
# Variable for the VPC CIDR block
variable "primary_vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  # default     = "10.0.0.0/16"
}

variable "secondary_vpc_cidr_block" {
  description = "CIDR block for the secondary VPC"
  type        = string
  # default     = "10.1.0.0/16"
}
