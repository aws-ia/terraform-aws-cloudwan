# --- examples/reference_global_network/main.tf ---

# Creating Global Network outside the module
resource "awscc_networkmanager_global_network" "global_network" {
  description = "Global Network - ${var.identifier}"

  tags = [{
    Key   = "Name",
    Value = "Global Network - ${var.identifier}"
  }]
}

# AWS Cloud WAN module - creating Core Network
module "cloudwan" {
  source  = "aws-ia/cloudwan/aws"
  version = "0.0.7"

  global_network = {
    create = false
    id     = awscc_networkmanager_global_network.global_network.id
  }

  core_network = {
    description     = "Global Network - AWS CloudWAN Module"
    policy_document = data.aws_networkmanager_core_network_policy_document.policy.json
  }

  tags = {
    Name = "core-network-${var.identifier}"
  }
}
