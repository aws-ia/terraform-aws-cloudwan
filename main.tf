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

# ---------- CENTRAL VPCS ----------
module "central_vpcs" {
  source   = "aws-ia/vpc/aws"
  version  = "4.4.4"
  for_each = try(var.central_vpcs, {})

  name       = try(each.value.name, each.key)
  cidr_block = try(each.value.cidr_block, null)
  az_count   = each.value.az_count

  vpc_ipv4_ipam_pool_id   = try(each.value.vpc_ipv4_ipam_pool_id, null)
  vpc_ipv4_netmask_length = try(each.value.vpc_ipv4_netmask_length, null)

  vpc_enable_dns_hostnames = try(each.value.vpc_enable_dns_hostnames, true)
  vpc_enable_dns_support   = try(each.value.vpc_enable_dns_support, true)
  vpc_instance_tenancy     = try(each.value.vpc_instance_tenancy, "default")

  vpc_flow_logs = try(each.value.vpc_flow_logs, { log_destination_type = "none" })

  core_network = {
    arn = try(aws_networkmanager_core_network.core_network[0].arn, var.core_network_arn)
    id  = try(aws_networkmanager_core_network.core_network[0].id, split("/", var.core_network_arn)[1])
  }
  core_network_routes = each.value.type == "shared_services" ? { for k, v in each.value.subnets : k => "0.0.0.0/0" if k != "public" || k != "core_network" } : local.core_network_routes[each.value.type]

  subnets = merge(
    local.subnets[each.value.type],
    { for k, subnet in try(each.value.subnets, {}) : k => merge(try(local.subnets[each.value.type][k], {}), subnet) }
  )

  tags = merge(
    module.tags.tags_aws,
    try(each.value.tags, {})
  )
}

# ---------- AWS NETWORK FIREWALL ----------
module "network_firewall" {
  source  = "aws-ia/networkfirewall/aws"
  version = "1.0.2"
  for_each = {
    for k, v in try(var.central_vpcs, {}) : k => v
    if contains(["inspection", "egress_with_inspection", "ingress_with_inspection"], v.type) && contains(keys(var.aws_network_firewall), k)
  }

  network_firewall_name        = var.aws_network_firewall[each.key].name
  network_firewall_description = var.aws_network_firewall[each.key].description
  network_firewall_policy      = var.aws_network_firewall[each.key].policy_arn

  network_firewall_delete_protection        = try(var.aws_network_firewall[each.key].delete_protection, false)
  network_firewall_policy_change_protection = try(var.aws_network_firewall[each.key].policy_change_protection, false)
  network_firewall_subnet_change_protection = try(var.aws_network_firewall[each.key].subnet_change_protection, false)

  vpc_id      = module.central_vpcs[each.key].vpc_attributes.id
  vpc_subnets = { for k, v in module.central_vpcs[each.key].private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "endpoints" }
  number_azs  = each.value.az_count

  routing_configuration = local.routing_configuration[each.key]

  tags = merge(
    module.tags.tags_aws,
    try(var.aws_network_firewall[each.key].tags, {})
  )
}

# For VPC type "ingress_with_inspection", IGW route table has to be created
resource "aws_route_table" "igw_route_table" {
  for_each = {
    for k, v in module.central_vpcs : k => v
    if var.central_vpcs[k].type == "ingress_with_inspection"
  }

  vpc_id = each.value.vpc_attributes.id
}

resource "aws_route_table_association" "igw_route_table_association" {
  for_each = {
    for k, v in module.central_vpcs : k => v
    if var.central_vpcs[k].type == "ingress_with_inspection"
  }

  gateway_id     = each.value.internet_gateway.id
  route_table_id = aws_route_table.igw_route_table[each.key].id
}

# For VPC type "ingress_with_inspection", we obtain the CIDR blocks of the public subnets
module "public_subnet_cidrs" {
  source = "./modules/subnet_cidrs"
  for_each = {
    for k, v in module.central_vpcs : k => v
    if var.central_vpcs[k].type == "ingress_with_inspection"
  }

  subnet_ids = { for i, j in each.value.public_subnet_attributes_by_az : i => j.id }
  number_azs = var.central_vpcs[each.key].az_count
}