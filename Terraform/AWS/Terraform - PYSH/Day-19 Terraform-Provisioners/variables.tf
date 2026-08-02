variable "key_name" {
    description = "The name of the SSH key pair to use for the instance"
    type        = string
}

variable "private_key_path" {
    description = "The path to the private key file for SSH access"
    type        = string
}

variable "instance_type" {
    description = "The type of instance to create"
    type        = string
    default     = "t2.micro"
}   

