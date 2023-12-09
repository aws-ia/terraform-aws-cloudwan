# --- examples/core_network_share/variables.tf ---

variable "identifier" {
  type        = string
  description = "Example identifier."

  default = "core-network-share"
}

variable "aws_region" {
  type        = string
  description = "AWS Region."

  default = "us-east-1"
}

variable "aws_account_share" {
  type        = string
  description = "AWS Account ID (to share the Core Network)"
}