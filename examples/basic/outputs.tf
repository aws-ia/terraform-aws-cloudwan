# --- examples/basic/outputs.tf ---

# Global Network ID
output "global_network_id" {
  value       = module.cloud_wan.global_network.id
  description = "Global Network ID."
}

# Core Network ID
output "core_network_id" {
  value       = module.cloud_wan.core_network.id
  description = "Core Network ID."
}