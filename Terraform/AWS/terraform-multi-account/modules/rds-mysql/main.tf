# =============================================================================
# RDS MySQL Module (Simplified)
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

resource "aws_db_subnet_group" "this" {
  name       = "${var.account_name}-${var.environment}-db-subnet"
  subnet_ids = var.subnet_ids

  tags = var.common_tags
}

resource "aws_db_instance" "this" {
  identifier             = "${var.account_name}-${var.environment}-mysql"
  engine                 = "mysql"
  engine_version         = var.engine_version
  instance_class         = var.instance_class          # e.g. db.m6i.large
  allocated_storage      = var.allocated_storage
  max_allocated_storage  = var.max_allocated_storage
  db_name                = var.db_name
  username               = var.username
  password               = var.password                # Use Secrets Manager in real life!
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.security_group_ids
  multi_az               = var.multi_az
  storage_encrypted      = true
  skip_final_snapshot    = var.skip_final_snapshot
  deletion_protection    = var.deletion_protection

  tags = var.common_tags
}
