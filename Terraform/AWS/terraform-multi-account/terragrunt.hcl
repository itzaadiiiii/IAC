# =============================================================================
# Root terragrunt.hcl
# This file is inherited by every stack. It generates backend.tf and provider.tf
# automatically so you never copy-paste them.
# =============================================================================

# -----------------------------------------------------------------------------
# Generate backend.tf (S3 + DynamoDB locking)
# -----------------------------------------------------------------------------
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "s3" {
    bucket         = "mycompany-terraform-state-prod"          # Change to your bucket
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
EOF
}

# -----------------------------------------------------------------------------
# Generate provider.tf with correct account AssumeRole
# -----------------------------------------------------------------------------
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "us-east-1"

  # Automatically assumes the role in the target account
  assume_role {
    role_arn = "arn:aws:iam::$${local.account_id}:role/TerraformExecutionRole"
  }

  default_tags {
    tags = {
      ManagedBy   = "Terragrunt"
      Repository  = "terraform-multi-account"
    }
  }
}
EOF
}

# -----------------------------------------------------------------------------
# Read account-specific values from account.hcl
# -----------------------------------------------------------------------------
locals {
  # Find the nearest account.hcl (walks up the folder tree)
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  account_id   = local.account_vars.locals.account_id
  account_name = local.account_vars.locals.account_name
  environment  = local.account_vars.locals.environment
}

# Common inputs available to all modules
inputs = {
  account_id   = local.account_id
  account_name = local.account_name
  environment  = local.environment

  common_tags = {
    Account     = local.account_name
    Environment = local.environment
    ManagedBy   = "Terragrunt"
  }
}
