# Resources created
output "core_network" {
  value       = module.cloudwan
  description = "Core Network - created with AWS CloudWAN module."
}

output "global_network" {
  value = aws_networkmanager_global_network.global_network
  description = "Global Network - created with AWS provider."
}