variable "table_name" {
  type = string
}

variable "billing_mode" {
  type    = string
  default = "PAY_PER_REQUEST"
}

variable "hash_key" {
  type = string
}

variable "range_key" {
  type    = string
  default = null
}

variable "enable_pitr" {
  type    = bool
  default = true
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
