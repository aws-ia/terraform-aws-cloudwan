# --- examples/basic/outputs.tf ---

# Global Network ID
output "global_network_id" {
  value       = module.cloudwan.global_network.id
  description = "Global Network ID."
}

# Core Network ID
output "core_network_id" {
  value       = module.cloudwan.core_network.core_network_id
  description = "Core Network ID."
}