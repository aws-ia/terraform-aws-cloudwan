# --- examples/central_vpcs_egress_shared_services/variables.tf ---

variable "identifier" {
  type        = string
  description = "Example identifier."

  default = "create-global-core-network"
}

variable "aws_region" {
  type        = string
  description = "AWS Region."

  default = "eu-west-1"
}