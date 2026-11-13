# =============================================================================
# ECS Module (Simplified skeleton)
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

resource "aws_ecs_cluster" "this" {
  name = "${var.account_name}-${var.environment}-ecs"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.common_tags
}

# Task definitions, services, ALB integration would be added here
