terraform {
  required_version = ">= 1.0.7"
  experiments      = [module_variable_optional_attrs]
  required_providers {
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 0.21.0"
    }
  }
}
