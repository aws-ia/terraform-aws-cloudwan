# --- root/main.tf ---

# ---------- GLOBAL NETWORK ----------
resource "aws_networkmanager_global_network" "global_network" {
  count = local.create_global_network ? 1 : 0

  description = var.global_network.description

  tags = merge(
    module.tags.tags_aws,
    module.global_network_tags.tags_aws
  )
}

# ---------- CORE NETWORK ----------
resource "aws_networkmanager_core_network" "core_network" {
  count = local.create_core_network ? 1 : 0

  description       = var.core_network.description
  global_network_id = local.create_global_network ? aws_networkmanager_global_network.global_network[0].id : var.global_network_id

  create_base_policy   = local.create_base_policy
  base_policy_document = try(var.core_network.base_policy_document, null)
  base_policy_regions  = try(var.core_network.base_policy_regions, null)

  tags = merge(
    module.tags.tags_aws,
    module.core_network_tags.tags_aws
  )
}

resource "aws_networkmanager_core_network_policy_attachment" "policy_attachment" {
  count = local.create_core_network ? 1 : 0

  core_network_id = aws_networkmanager_core_network.core_network[0].id
  policy_document = var.core_network.policy_document
}

# ---------- RAM SHARE (CORE NETWORK) ----------
# RAM Resource Share
resource "aws_ram_resource_share" "resource_share" {
  count = local.create_ram_resources && local.create_core_network ? 1 : 0

  name                      = var.core_network.resource_share_name
  allow_external_principals = try(var.core_network.resource_share_allow_external_principals, null)

  tags = merge(
    module.tags.tags_aws,
    module.core_network_tags.tags_aws
  )
}

# RAM Resource Association
resource "aws_ram_resource_association" "resource_association" {
  count = local.create_ram_resources && local.create_core_network ? 1 : 0

  resource_arn       = aws_networkmanager_core_network.core_network[0].arn
  resource_share_arn = aws_ram_resource_share.resource_share[0].arn
}

# RAM Principal Association
resource "aws_ram_principal_association" "principal_association" {
  count = local.create_ram_resources && local.create_core_network ? length(try(var.core_network.ram_share_principals, [])) : 0

  principal          = var.core_network.ram_share_principals[count.index]
  resource_share_arn = aws_ram_resource_share.resource_share[0].arn
}
