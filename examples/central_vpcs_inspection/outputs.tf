# --- examples/central_vpcs_inspection/outputs.tf ---

output "cloud_wan" {
  description = "AWS Cloud WAN resources."
  value = {
    global_network = module.cloud_wan.global_network.id
    core_network   = module.cloud_wan.core_network.id
  }
}

output "central_vpcs" {
  description = "Central VPC IDs."
  value       = { for k, v in module.cloudwan_central_vpcs.central_vpcs : k => v.vpc_attributes.id }
}

output "aws_network_firewall" {
  description = "AWS Network Firewall IDs."
  value       = { for k, v in module.cloudwan_central_vpcs.aws_network_firewall : k => v.id }
}
