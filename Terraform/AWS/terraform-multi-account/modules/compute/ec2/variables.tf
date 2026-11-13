variable "instance_type" {
  description = "EC2 instance type (e.g. m6i.large, t3.medium)"
  type        = string
  default     = "m6i.large"
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "ami_id" {
  description = "AMI ID to use"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to launch instances into"
  type        = list(string)
}

variable "vpc_id" {
  type = string
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed to SSH"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  type    = string
  default = null
}

variable "root_volume_size" {
  type    = number
  default = 30
}

variable "account_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
