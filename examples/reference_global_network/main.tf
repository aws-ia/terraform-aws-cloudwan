# --- examples/reference_global_network/main.tf ---

# Creating Global Network outside the module
resource "aws_networkmanager_global_network" "global_network" {
  description = "Global Network - ${var.identifier}"

  tags = {
    Name = "Global Network - ${var.identifier}"
  }
}

# AWS Cloud WAN module - creating Core Network
module "cloudwan" {
  source = "../.."

  global_network_id = aws_networkmanager_global_network.global_network.id

  core_network = {
    description     = "Global Network - AWS CloudWAN Module"
    policy_document = data.aws_networkmanager_core_network_policy_document.policy.json

    tags = {
      Name = "core-network"
    }
  }

  tags = {
    Project = var.identifier
  }
}
