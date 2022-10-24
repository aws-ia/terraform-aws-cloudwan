# --- examples/reference_global_network/outputs.tf ---

# Global Network ID
output "global_network_id" {
  value       = awscc_networkmanager_global_network.global_network.id
  description = "Global Network ID."
}

# Core Network ID
output "core_network_id" {
  value       = module.cloudwan.core_network.core_network_id
  description = "Core Network ID."
}
