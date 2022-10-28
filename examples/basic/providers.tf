# --- examples/basic/providers.tf ---

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 0.36.0"
    }
  }
}

provider "aws" {}

provider "awscc" {}
