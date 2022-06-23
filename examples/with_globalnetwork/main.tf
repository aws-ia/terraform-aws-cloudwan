# Calling the CloudWAN Module
module "cloudwan" {
  source = "../.."

  global_network = {
    id = aws_networkmanager_global_network.global_network.id
  }
  core_network = {
    description     = "Global Network - AWS CloudWAN Module"
    policy_document = data.aws_networkmanager_core_network_policy_document.main.json
  }

  tags = {
    Name = "cloudwan-module-with"
  }
}

# Creating a Global Network using the AWS Provider
resource "aws_networkmanager_global_network" "global_network" {
  description = "Global Network - CloudWAN"

  tags = {
    Name      = "Global Network CloudWAN"
    Terraform = "Managed"
    Provider  = "aws"
  }
}

data "aws_networkmanager_core_network_policy_document" "main" {
  core_network_configuration {
    vpn_ecmp_support = false
    asn_ranges       = ["64512-64555"]
    edge_locations {
      location = "us-east-1"
      asn      = 64512
    }
  }

  segments {
    name                          = "shared"
    description                   = "SegmentForSharedServices"
    require_attachment_acceptance = true
  }

  segment_actions {
    action     = "share"
    mode       = "attachment-route"
    segment    = "shared"
    share_with = ["*"]
  }

  attachment_policies {
    rule_number     = 1
    condition_logic = "or"

    conditions {
      type     = "tag-value"
      operator = "equals"
      key      = "segment"
      value    = "shared"
    }
    action {
      association_method = "constant"
      segment            = "shared"
    }
  }
}
