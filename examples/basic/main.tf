# --- examples/basic/main.tf ---

# Calling the CloudWAN Module - we are creating both the Global Network and the Core Network
module "cloudwan" {
  source  = "aws-ia/cloudwan/aws"
  version = "0.0.7"

  global_network = {
    create      = true
    description = "Global Network - ${var.identifier}"
  }

  core_network = {
    description     = "Core Network - ${var.identifier}"
    policy_document = data.aws_networkmanager_core_network_policy_document.policy.json
  }

  tags = {
    Name = var.identifier
  }
}

data "aws_networkmanager_core_network_policy_document" "policy" {
  core_network_configuration {
    vpn_ecmp_support = false
    asn_ranges       = ["64515-64520"]
    edge_locations {
      location = "eu-west-1"
    }
  }

  segments {
    name                          = "shared"
    description                   = "SegmentForSharedServices"
    require_attachment_acceptance = true
  }
}
