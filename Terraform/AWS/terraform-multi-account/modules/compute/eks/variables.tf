variable "cluster_role_arn" {
  type = string
}

variable "kubernetes_version" {
  type    = string
  default = "1.30"
}

variable "subnet_ids" {
  type = list(string)
}

variable "public_access" {
  type    = bool
  default = false
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
