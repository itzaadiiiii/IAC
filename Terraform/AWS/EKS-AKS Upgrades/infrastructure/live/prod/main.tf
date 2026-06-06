terraform {
  required_version = ">= 1.5.0"
  
  backend "s3" {
    bucket         = "fintech-terraform-state-prod"
    key            = "eks/prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

module "eks_prod_primary" {
  source = "../../modules/eks"

  cluster_name    = "fintech-prod-primary-01"
  cluster_version = "1.30" # UPGRADE TARGET (Latest Enterprise Stable)
  environment     = "prod"

  vpc_id     = "vpc-0123456789abcdef0"
  subnet_ids = ["subnet-abc", "subnet-def", "subnet-ghi"]
}
