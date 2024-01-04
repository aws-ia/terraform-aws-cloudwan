# --- modules/subnet_cidrs/main.tf ---

locals {
  # List of Availability Zone IDs from map
  azs = keys(var.subnet_ids)
  # List of Subnet IDs from map
  subnet_ids = values(var.subnet_ids)
}

data "aws_subnet" "subnet" {
  count = var.number_azs

  id = local.subnet_ids[count.index]
}