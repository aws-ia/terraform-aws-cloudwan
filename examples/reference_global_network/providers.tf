# --- examples/reference_global_network/providers.tf ---

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.50.0"
    }
  }
}

provider "aws" {}
