# --- root/outputs.tf ---

# GLOBAL NETORK
output "global_network" {
  value       = local.create_global_network ? aws_networkmanager_global_network.global_network[0] : null
  description = "Global Network. Full output of aws_networkmanager_global_network."
}

# CORE NETWORK
output "core_network" {
  value       = local.create_core_network ? aws_networkmanager_core_network.core_network[0] : null
  description = "Core Network. Full output of aws_networkmanager_core_network."
}

# RESOURCE SHARE
output "ram_resource_share" {
  value       = local.create_ram_resources ? aws_ram_resource_share.resource_share[0] : null
  description = "Resource Access Manager (RAM) Resource Share. Full output of aws_ram_resource_share."
}

# CENTRAL VPCS
output "central_vpcs" {
  value       = try(module.central_vpcs, null)
  description = "Central VPC information. Full output of VPC module - https://registry.terraform.io/modules/aws-ia/vpc/aws/latest."
}

# AWS NETWORK FIREWALL
output "aws_network_firewall" {
  value       = { for k, v in try(module.network_firewall, {}) : k => v.aws_network_firewall }
  description = "AWS Network Firewall. Full output of aws_networkfirewall_firewall."
}