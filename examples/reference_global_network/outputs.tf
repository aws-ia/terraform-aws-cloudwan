# --- examples/reference_global_network/outputs.tf ---

# Global Network ID
output "global_network_id" {
  value       = aws_networkmanager_global_network.global_network.id
  description = "Global Network ID."
}

# Core Network ID
output "core_network_id" {
  value       = module.cloudwan.core_network.id
  description = "Core Network ID."
}
