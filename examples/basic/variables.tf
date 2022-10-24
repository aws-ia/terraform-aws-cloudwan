# --- examples/basic/variables.tf ---

variable "identifier" {
  type        = string
  description = "Example identifier."

  default = "create-global-core-network"
}