# =============================================================================
# EKS Module (Simplified skeleton)
# In real projects use the official terraform-aws-modules/eks module
# =============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# This is a skeleton. Replace with full implementation or official module:
# source = "terraform-aws-modules/eks/aws"
# version = "~> 20.0"

resource "aws_eks_cluster" "this" {
  name     = "${var.account_name}-${var.environment}-eks"
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = var.public_access
  }

  tags = var.common_tags
}

# Node group, addons, etc. would go here in a real module
