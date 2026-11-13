# =============================================================================
# Staging - Compute Stack
# Example: Launch m6i.large EC2 instances in Staging account
# =============================================================================

include "root" {
  path = find_in_parent_folders()
}

# Depend on the network stack so we can use its outputs (VPC, subnets)
dependency "network" {
  config_path = "../network"

  mock_outputs = {
    vpc_id             = "vpc-xxxxxxxx"
    private_subnet_ids = ["subnet-aaaa", "subnet-bbbb"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

terraform {
  source = "../../../../../../modules/compute/ec2"
}

inputs = {
  # ---------- This is how you launch m6i.large in Staging ----------
  instance_type  = "m6i.large"          # <--- requested instance type
  instance_count = 2

  # Use private subnets from the network stack
  vpc_id     = dependency.network.outputs.vpc_id
  subnet_ids = dependency.network.outputs.private_subnet_ids

  # Replace with a real AMI (Amazon Linux 2023 example)
  ami_id = "ami-0c7217cdde317cfec"      # us-east-1 Amazon Linux 2023

  ssh_cidr_blocks = ["10.0.0.0/8"]
  root_volume_size = 50

  # account_name / environment / common_tags come automatically from root
}
