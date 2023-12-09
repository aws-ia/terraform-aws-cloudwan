# --- root/outputs.tf ---

# GLOBAL NETORK (if created)
output "global_network" {
  value       = local.create_global_network ? aws_networkmanager_global_network.global_network[0] : null
  description = "Global Network. Full output of aws_networkmanager_global_network."
}

# CORE NETWORK (if created)
output "core_network" {
  value       = local.create_core_network ? aws_networkmanager_core_network.core_network[0] : null
  description = "Core Network. Full output of aws_networkmanager_core_network."
}

# RESOURCE SHARE (if created)
output "ram_resource_share" {
  value       = local.create_ram_resources ? aws_ram_resource_share.resource_share[0] : null
  description = "Resource Access Manager (RAM) Resource Share. Full output of aws_ram_resource_share."
}
