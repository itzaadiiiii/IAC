# =============================================================================
# Production - Compute Stack
# =============================================================================

include "root" {
  path = find_in_parent_folders()
}

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
  instance_type    = "m6i.large"
  instance_count   = 3                    # More instances in prod
  vpc_id           = dependency.network.outputs.vpc_id
  subnet_ids       = dependency.network.outputs.private_subnet_ids
  ami_id           = "ami-0c7217cdde317cfec"
  root_volume_size = 100
}
