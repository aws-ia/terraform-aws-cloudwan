# --- examples/central_vpcs_inspection/variables.tf ---

variable "identifier" {
  type        = string
  description = "Example identifier."

  default = "central-vpcs-inspection"
}

variable "aws_region" {
  type        = string
  description = "AWS Region."

  default = "eu-west-1"
}