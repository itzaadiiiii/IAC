# =============================================================================
# Staging - Network Stack
# =============================================================================

include "root" {
  path = find_in_parent_folders()
}

terraform {
  # In real life prefer a versioned git source:
  # source = "git::https://github.com/myorg/terraform-modules.git//network?ref=v1.2.0"
  source = "../../../../../../modules/network"
}

inputs = {
  vpc_cidr = "10.20.0.0/16"

  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

  public_subnet_cidrs   = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
  private_subnet_cidrs  = ["10.20.11.0/24", "10.20.12.0/24", "10.20.13.0/24"]
  database_subnet_cidrs = ["10.20.21.0/24", "10.20.22.0/24", "10.20.23.0/24"]

  enable_nat_gateway = true

  # account_name, environment, common_tags come from root terragrunt.hcl
}
