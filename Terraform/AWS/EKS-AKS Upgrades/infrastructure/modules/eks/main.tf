module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = false
  cluster_endpoint_private_access = true

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  # Enterprise Security Controls
  enable_irsa = true
  
  # Encryption
  create_kms_key = true
  cluster_encryption_config = {
    resources = ["secrets"]
  }

  # Addons (Core for Robo-Advisory)
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  # Immutable Node Groups
  # Naming convention includes version to force replacement (Blue/Green style)
  eks_managed_node_groups = {
    "general-${replace(var.cluster_version, ".", "-")}" = {
      min_size     = 2
      max_size     = 4
      desired_size = 2

      instance_types = ["m6a.2xlarge"]
      capacity_type  = "ON_DEMAND"
      
      labels = {
        workload = "general"
        env      = var.environment
      }

      # Ensure replacement is safe
      update_config = {
        max_unavailable = 1
      }
    }

    "cpu-${replace(var.cluster_version, ".", "-")}" = {
      min_size     = 1
      max_size     = 3
      desired_size = 1

      instance_types = ["c5.xlarge"]
      capacity_type  = "ON_DEMAND"
      
      labels = {
        workload = "cpu-intensive"
      }
    }

    "ml-${replace(var.cluster_version, ".", "-")}" = {
      min_size     = 1
      max_size     = 3
      desired_size = 1

      instance_types = ["r5.xlarge"]
      capacity_type  = "ON_DEMAND"
      
      labels = {
        workload = "ml-workload"
      }
      
      taints = {
        dedicated = {
          key    = "workload"
          value  = "ml"
          effect = "NO_SCHEDULE"
        }
      }
    }
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
    Owner       = "PlatformEngineering"
  }
}
