# --- examples/central_vpcs/main.tf ---

# AWS Cloud WAN module
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

module "cwan_central_vpcs" {
  source = "../.."

  core_network_arn = module.cloud_wan.core_network.arn

  ipv4_network_definition = "10.0.0.0/8"
  central_vpcs = {
    egress = {
      type       = "egress"
      cidr_block = "10.10.0.0/24"
      az_count   = 2

      subnets = {
        public = { cidrs = ["10.10.0.0/28", "10.10.0.16/28"] }
        core_network = {
          cidrs = ["10.10.0.32/28", "10.10.0.48/28"]

          tags = { domain = "egress" }
        }
      }
    }
    egress-with-inspection = {
      type       = "egress_with_inspection"
      cidr_block = "10.10.1.0/24"
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
    shared-services = {
      type       = "shared_services"
      cidr_block = "10.10.2.0/24"
      az_count   = 2

      subnets = {
        vpc_endpoints = { netmask = 28 }
        hybrid_dns    = { netmask = 28 }
        core_network = {
          netmask = 28

          tags = { domain = "shared" }
        }
      }
    }
    inspection = {
      type       = "inspection"
      cidr_block = "10.10.3.0/24"
      az_count   = 2

      subnets = {
        endpoints = { cidrs = ["10.10.3.0/28", "10.10.3.16/28"] }
        core_network = {
          cidrs = ["10.10.3.32/28", "10.10.3.48/28"]

          tags = { domain = "inspection" }
        }
      }
    }
    ingress = {
      type       = "ingress"
      cidr_block = "10.10.4.0/24"
      az_count   = 2

      subnets = {
        public = { netmask = 28 }
        core_network = {
          netmask = 28

          tags = { domain = "ingress" }
        }
      }
    }
    ingress-with-inspection = {
      type       = "ingress_with_inspection"
      cidr_block = "10.10.5.0/24"
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
}

# Core Network policy
locals {
  segments = ["egress", "ingress", "inspection", "shared"]
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