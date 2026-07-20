#Reading the default VPC
# fetches information about the Default VPC, including:
# - VPC ID
# - CIDR block
# - Tags
# - ARN
# - Default route table ID
# - etc.
#
# For example, you can access:
# data.aws_vpc.default.id
# data.aws_vpc.default.cidr_block

data "aws_vpc" "default" {
  default = true
}
