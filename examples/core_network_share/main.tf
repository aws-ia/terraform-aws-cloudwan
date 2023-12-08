# --- examples/core_network_share/main.tf ---

# AWS Cloud WAN module
module "cloud_wan" {
  source = "../.."

  global_network = {
    description = "Global Network - ${var.identifier}"

    tags = {
      Name = "global-network"
    }
  }

  core_network = {
    description     = "Core Network - ${var.identifier}"
    policy_document = data.aws_networkmanager_core_network_policy_document.policy.json

    resource_share_name                      = var.identifier
    resource_share_allow_external_principals = true
    ram_share_principals                     = [var.aws_account_share]

    tags = {
      Name = "core-network"
    }
  }

  tags = {
    Project = var.identifier
  }
}

data "aws_networkmanager_core_network_policy_document" "policy" {
  core_network_configuration {
    vpn_ecmp_support = false
    asn_ranges       = ["64515-64520"]
    edge_locations {
      location = var.aws_region
    }
  }

  segments {
    name                          = "shared"
    description                   = "SegmentForSharedServices"
    require_attachment_acceptance = true
  }
}