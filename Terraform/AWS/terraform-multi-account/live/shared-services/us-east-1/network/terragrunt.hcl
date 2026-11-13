# =============================================================================
# Shared Services - Central Network (TGW, shared services VPC, etc.)
# =============================================================================

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../../../modules/network"
}

inputs = {
  vpc_cidr = "10.0.0.0/16"

  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  enable_nat_gateway = true
}
