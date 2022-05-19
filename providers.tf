terraform {
  required_version = ">= 0.15.3"
  experiments      = [module_variable_optional_attrs]
  required_providers {
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 0.21.0"
    }
  }
}
