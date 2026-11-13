variable "node_type" {
  type    = string
  default = "cache.m6g.large"
}

variable "num_cache_clusters" {
  type    = number
  default = 2
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "automatic_failover" {
  type    = bool
  default = true
}

variable "multi_az" {
  type    = bool
  default = true
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
