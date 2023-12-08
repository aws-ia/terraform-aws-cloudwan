# --- root/data.tf ---

locals {
  # ---------- CREATION OF RESOURCES ----------
  # Global Network & Core Network
  create_global_network = length(keys(var.global_network)) > 0
  create_core_network   = length(keys(var.core_network)) > 0
  # Base Policy
  create_base_policy = (try(var.core_network.base_policy_document, null) == null) && (try(var.core_network.base_policy_regions, null) == null) ? false : true
  # RAM Resources
  create_ram_resources = try(var.core_network.resource_share_name, null) != null
}

# Sanitizes tags
module "tags" {
  source  = "aws-ia/label/aws"
  version = "0.0.5"

  tags = var.tags
}

module "global_network_tags" {
  source  = "aws-ia/label/aws"
  version = "0.0.5"

  tags = try(var.global_network.tags, {})
}

module "core_network_tags" {
  source  = "aws-ia/label/aws"
  version = "0.0.5"

  tags = try(var.core_network.tags, {})
}