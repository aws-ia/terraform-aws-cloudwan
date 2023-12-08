# --- examples/base_policy/main.tf ---

# Calling the CloudWAN Module - we are creating both the Global Network and the Core Network
module "cloud_wan" {
  source = "../.."

  global_network = {
    description = "Global Network - ${var.identifier}"

    tags = {
      Name = "global-network"
    }
  }

  core_network = {
    description         = "Core Network - ${var.identifier}"
    policy_document     = data.aws_networkmanager_core_network_policy_document.policy.json
    base_policy_regions = [var.aws_region]

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
