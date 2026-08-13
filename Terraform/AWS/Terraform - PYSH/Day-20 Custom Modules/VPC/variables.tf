variable "cidr_block" {
    description = "The CIDR block for the VPC"
    type        = string
    default     = "10.0.0.0/16"
}

variable "name_prefix" {
    description = "The prefix for naming resources"
    type        = string
    default     = "myapp"
}

variable "public_subnet_cidr" {
    description = "The CIDR block for the public subnet"
    type        = string
    default     = "10.0.1.0/24"
}

variable "public_subnet_az" {
    description = "The availability zone for the public subnet"
    type        = string
    default     = data.aws_availability_zones.available.names[0]
}   