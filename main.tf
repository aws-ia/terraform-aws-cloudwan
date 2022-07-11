
# GLOBAL NETWORK - Optionally created if it is not supplied as variable
resource "awscc_networkmanager_global_network" "global_network" {
  count = var.create_global_network ? 1 : 0

  description = var.global_network.description

  tags = module.tags.tags
}

# CORE NETWORK
resource "awscc_networkmanager_core_network" "core_network" {
  description       = var.core_network.description
  global_network_id = var.create_global_network ? awscc_networkmanager_global_network.global_network[0].id : var.global_network.id
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
