# --- root/providers.tf ---

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 0.36.0"
    }
  }
}
