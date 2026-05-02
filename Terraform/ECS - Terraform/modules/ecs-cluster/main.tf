    resource "aws_ecs_cluster" "main" {
    name = var.cluster_name

    setting {
        name  = "containerInsights"
        value = "enabled"
    }

    tags = {
        Name        = var.cluster_name
        Environment = var.environment
    }
    }

    # CloudWatch Log Group for containers
    resource "aws_cloudwatch_log_group" "main" {
    name              = "/ecs/${var.cluster_name}"
    retention_in_days = 30
    }