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

