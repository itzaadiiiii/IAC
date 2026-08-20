# Custom VPC Module
module "vpc" {
  source = "./modules/vpc"

  name_prefix     = var.cluster_name
  vpc_cidr        = var.vpc_cidr
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  # Required tags for EKS
  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
    Project     = "EKS-Day20"
  }
}


# Custom IAM Module
module "iam" {
  source = "./modules/iam"

  cluster_name = var.cluster_name

  tags = {
    Environment = var.environment
    Terraform   = "true"
    Project     = "EKS-Day20"
  }
}