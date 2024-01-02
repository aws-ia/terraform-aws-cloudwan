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

  # ---------- CENTRAL VPC - SUBNETS CONFIGURATION ----------
  subnets = {
    inspection = {
      endpoints    = { name_prefix = "endpoints" }
      core_network = { appliance_mode_support = true }
    }
    egress = {
      public = { nat_gateway_configuration = "all_azs" }
      core_network = {
        appliance_mode_support  = false
        connect_to_public_natgw = true
      }
    }
    egress_with_inspection = {
      public       = { nat_gateway_configuration = "all_azs" }
      endpoints    = { connect_to_public_natgw = true }
      core_network = { appliance_mode_support = true }
    }
    shared_services = {
      core_network = { appliance_mode_support = false }
    }
    ingress = {
      public       = { nat_gateway_configuration = "none" }
      core_network = { appliance_mode_support = false }
    }
    ingress_with_inspection = {
      endpoints = { name_prefix = "endpoints" }
      public = {
        nat_gateway_configuration = "none"
        connect_to_igw            = false
      }
      core_network = { appliance_mode_support = false }
    }
  }

  # ---------- CENTRAL VPC - CORE NETWORK ROUTES CONFIGURATION ----------
  core_network_routes = {
    inspection              = { endpoints = "0.0.0.0/0" }
    egress                  = { public = var.ipv4_network_definition }
    egress_with_inspection  = { endpoints = var.ipv4_network_definition }
    ingress                 = { public = var.ipv4_network_definition }
    ingress_with_inspection = { public = var.ipv4_network_definition }
  }
}

# ---------- SANITIZES TAGS ---------
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