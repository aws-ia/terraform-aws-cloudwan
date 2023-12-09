# --- examples/core_network_share/outputs.tf ---

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

# AWS RAM Resource Share
output "ram_resource_share" {
  value       = module.cloud_wan.ram_resource_share.arn
  description = "AWS RAM Resource Share."
}