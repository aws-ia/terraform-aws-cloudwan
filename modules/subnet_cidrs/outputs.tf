# --- modules/subnet_cidrs/outputs.tf ---

output "subnet_cidrs" {
  description = "VPC subnet CIDRs."
  value       = zipmap(local.azs, data.aws_subnet.subnet[*].cidr_block)
}