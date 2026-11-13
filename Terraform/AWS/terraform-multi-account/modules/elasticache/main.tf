# =============================================================================
# ElastiCache (Redis) Module - Simplified
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

resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.account_name}-${var.environment}-redis"
  subnet_ids = var.subnet_ids
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id       = "${var.account_name}-${var.environment}-redis"
  description                = "Redis cluster for ${var.environment}"
  node_type                  = var.node_type              # e.g. cache.m6g.large
  num_cache_clusters         = var.num_cache_clusters
  port                       = 6379
  subnet_group_name          = aws_elasticache_subnet_group.this.name
  security_group_ids         = var.security_group_ids
  automatic_failover_enabled = var.automatic_failover
  multi_az_enabled           = var.multi_az
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  tags = var.common_tags
}
