# --- root/outputs.tf ---

# GLOBAL NETORK (if created)
output "global_network" {
  value       = var.global_network.create ? aws_networkmanager_global_network.global_network[0] : null
  description = "Global Network. Full output of aws_networkmanager_global_network."
}

# CORE NETWORK
output "core_network" {
  value       = aws_networkmanager_core_network.core_network
  description = "Core Network. Full output of aws_networkmanager_core_network."
}
