# =============================================================================
# Lambda Module (Simplified)
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

resource "aws_lambda_function" "this" {
  function_name = "${var.account_name}-${var.environment}-${var.function_name}"
  role          = var.lambda_role_arn
  handler       = var.handler
  runtime       = var.runtime
  filename      = var.filename          # or use s3_bucket / s3_key
  timeout       = var.timeout
  memory_size   = var.memory_size

  environment {
    variables = var.environment_variables
  }

  tags = var.common_tags
}
