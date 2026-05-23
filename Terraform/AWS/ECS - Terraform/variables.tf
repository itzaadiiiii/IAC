    variable "region" {
    description = "AWS Region"
    type        = string
    default     = "us-east-1"
    }

    variable "environment" {
    description = "Environment name"
    type        = string
    }

    variable "project_name" {
    description = "Project name for resource naming"
    type        = string
    }

    variable "default_tags" {
    description = "Default tags for all resources"
    type        = map(string)
    default = {
        Terraform   = "true"
        Environment = "prod" # overridden per env
    }
    }

    # VPC
    variable "vpc_cidr" { type = string }
    variable "azs"      { type = list(string) }

    # ECS
    variable "ecs_cluster_name" { type = string }
    variable "container_image"  { type = string }
    variable "container_port"   { type = number }
    variable "cpu"              { type = number }
    variable "memory"           { type = number }
    variable "desired_count"    { type = number }

    # More variables as needed (domain, cert_arn, etc.)