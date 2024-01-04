# --- modules/subnet_cidrs/variables.tf ---

variable "subnet_ids" {
  description = "VPC subnet IDs."
  type        = map(string)
}

variable "number_azs" {
  description = "Number of AZs in the VPC."
  type        = string
}