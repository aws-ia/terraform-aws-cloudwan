# --- examples/basic/variables.tf ---

variable "identifier" {
  type        = string
  description = "Example identifier."

  default = "base-policy"
}

variable "aws_region" {
  type        = string
  description = "AWS Region."

  default = "eu-west-1"
}