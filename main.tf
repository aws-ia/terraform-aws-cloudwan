# GLOBAL NETWORK - Optionally created if it is not supplied as variable
resource "awscc_networkmanager_global_network" "global_network" {
    count = try(var.global_network.id, false) ? 1 : 0
    
    description = "Global Network - ${var.global_network.name}"

    tags = concat(module.tags.tags,
    [{
      key   = "Name"
      value = var.global_network.name
    }]
  )
}

# CORE NETWORK
resource "awscc_networkmanager_core_network" "core_network" {
    description = "Core Network - ${var.core_network.name}"
    global_network_id = try(var.global_network.id, false) ? var.global_network.id : awscc_networkmanager_global_network.global_network.id
    policy_document = var.core_network.policy_document
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