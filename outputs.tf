# GLOBAL NETORK (if created)
output "global_network" {
  value       = awscc_networkmanager_core_network.core_network.global_network_id
  description = "Global Network information."
}

# CORE NETWORK
output "core_network" {
  value       = awscc_networkmanager_core_network.core_network
  description = "Core Network information."
}
