terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the cluster and workers will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the cluster and workers"
  type        = list(string)
}

variable "environment" {
  description = "Environment name (dev, qa, stage, prod, dr)"
  type        = string
}
