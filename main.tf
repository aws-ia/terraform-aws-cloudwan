# --- root/main.tf ---

# GLOBAL NETWORK - Created only when indicated in var.create_global_network
resource "awscc_networkmanager_global_network" "global_network" {
  count = var.global_network.create ? 1 : 0

  description = var.global_network.description

  tags = module.tags.tags
}

# CORE NETWORK
resource "awscc_networkmanager_core_network" "core_network" {
  description       = var.core_network.description
  global_network_id = var.global_network.create ? awscc_networkmanager_global_network.global_network[0].id : var.global_network.id
  policy_document   = jsonencode(jsondecode(var.core_network.policy_document))

  tags = module.tags.tags
}

# Sanitizes tags for both aws / awscc providers
# aws   tags = module.tags.tags_aws
# awscc tags = module.tags.tags
module "tags" {
  source  = "aws-ia/label/aws"
  version = "0.0.5"

  tags = var.tags
}
