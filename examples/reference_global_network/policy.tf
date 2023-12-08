# --- examples/reference_global_network/policy.tf ---

# Core Network policy document - using the data source
data "aws_networkmanager_core_network_policy_document" "policy" {

  core_network_configuration {
    vpn_ecmp_support = false
    asn_ranges       = ["64512-64520"]
    edge_locations {
      location = "us-east-1"
      asn      = 64512
    }
    edge_locations {
      location = "eu-west-1"
      asn      = 64513
    }
  }

  segments {
    name                          = "prod"
    description                   = "Production traffic"
    require_attachment_acceptance = true
  }
  segments {
    name                          = "shared"
    description                   = "Shared Services"
    require_attachment_acceptance = false
  }

  segment_actions {
    action     = "share"
    mode       = "attachment-route"
    segment    = "shared"
    share_with = ["*"]
  }

  attachment_policies {
    rule_number     = 100
    condition_logic = "or"

    conditions {
      type     = "tag-value"
      operator = "equals"
      key      = "env"
      value    = "shared"
    }
    action {
      association_method = "constant"
      segment            = "shared"
    }
  }

  attachment_policies {
    rule_number     = 200
    condition_logic = "or"

    conditions {
      type     = "tag-value"
      operator = "equals"
      key      = "env"
      value    = "prod"
    }
    action {
      association_method = "constant"
      segment            = "prod"
    }
  }
}