# --- examples/central_vpcs_inspection/main.tf ---

# AWS Cloud WAN module - Calling the module first time to create Global Network & Core Network
module "cloud_wan" {
  source = "../.."

  global_network = {
    description = "Global Network"

    tags = {
      Name = "global-network"
    }
  }

  core_network = {
    description     = "Core Network"
    policy_document = data.aws_networkmanager_core_network_policy_document.policy.json

    tags = {
      Name = "core-network"
    }
  }
}

# AWS Cloud WAN module - Global Network, Core Network, and Central VPCs (with inspection)
module "cloudwan_central_vpcs" {
  source = "../.."

  core_network_arn = module.cloud_wan.core_network.arn

  ipv4_network_definition = "10.0.0.0/8"
  central_vpcs = {
    inspection = {
      type       = "inspection"
      cidr_block = "10.10.0.0/24"
      az_count   = 2

      subnets = {
        endpoints = { netmask = 28 }
        core_network = {
          netmask = 28

          tags = { domain = "inspection" }
        }
      }
    }
    egress-inspection = {
      type       = "egress_with_inspection"
      cidr_block = "10.10.2.0/24"
      az_count   = 2

      subnets = {
        public    = { netmask = 28 }
        endpoints = { netmask = 28 }
        core_network = {
          netmask = 28

          tags = { domain = "egress" }
        }
      }
    }
    ingress-inspection = {
      type       = "ingress_with_inspection"
      cidr_block = "10.10.2.0/24"
      az_count   = 2

      subnets = {
        endpoints = { netmask = 28 }
        public    = { netmask = 28 }
        core_network = {
          netmask = 28

          tags = { domain = "ingress" }
        }
      }
    }
  }

  aws_network_firewall = {
    inspection = {
      name        = "anfw-inspection"
      description = "AWS Network Firewall - East/West"
      policy_arn  = aws_networkfirewall_firewall_policy.inspection_policy.arn
    }
    egress-inspection = {
      name        = "anfw-egress-inspection"
      description = "AWS Network Firewall - Egress"
      policy_arn  = aws_networkfirewall_firewall_policy.egress_policy.arn
    }
    ingress-inspection = {
      name        = "anfw-ingress-inspection"
      description = "AWS Network Firewall - Ingress"
      policy_arn  = aws_networkfirewall_firewall_policy.ingress_policy.arn
    }
  }
}

# Core Network policy
locals {
  segments = ["prod", "inspection", "egress", "ingress"]
}

data "aws_networkmanager_core_network_policy_document" "policy" {
  core_network_configuration {
    vpn_ecmp_support = false
    asn_ranges       = ["64515-64520"]
    edge_locations {
      location = var.aws_region
    }
  }

  dynamic "segments" {
    for_each = local.segments
    iterator = segment

    content {
      name                          = segment.value
      require_attachment_acceptance = false
      isolate_attachments           = false
    }
  }

  attachment_policies {
    rule_number     = 100
    condition_logic = "or"

    conditions {
      type = "tag-exists"
      key  = "domain"
    }

    action {
      association_method = "tag"
      tag_value_of_key   = "domain"
    }
  }
}