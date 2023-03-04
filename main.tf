# --- root/main.tf ---

# GLOBAL NETWORK - Created only when indicated in var.create_global_network
resource "aws_networkmanager_global_network" "global_network" {
  count = var.global_network.create ? 1 : 0

  description = var.global_network.description

  tags = module.tags.tags_aws
}

# Local variable to determine if the base_policy has to be created
locals {
  create_base_policy = var.core_network.base_policy_regions == null ? false : true
}

# CORE NETWORK
resource "aws_networkmanager_core_network" "core_network" {
  description       = var.core_network.description
  global_network_id = var.global_network.create ? aws_networkmanager_global_network.global_network[0].id : var.global_network.id

  create_base_policy  = local.create_base_policy
  base_policy_regions = var.core_network.base_policy_regions

  tags = module.tags.tags_aws
}

# CORE NETWORK POLICY ATTACHMENT
resource "aws_networkmanager_core_network_policy_attachment" "policy_attachment" {
  core_network_id = aws_networkmanager_core_network.core_network.id
  policy_document = var.core_network.policy_document
}

# Sanitizes tags
module "tags" {
  source  = "aws-ia/label/aws"
  version = "0.0.5"

  tags = var.tags
}
