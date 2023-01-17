# --- root/variables.tf ---

# Global Network variables
variable "global_network" {
  description = <<-EOF
  Global Network definition. This variable expects the following attributes:
  - `create = (Required|string) Indicating if a Global Network should be created or not. Default to `true`.
  - `id` = (Optional|string) ID of a current Global Network created outside the module. Attribute required when `var.create_global_network` is **false**.
  - `description` = (Optional|string) Description of the new Global Network to create. Attribute required when `var.create_global_network` is **true**.
  ```
EOF
  type = object({
    create      = bool
    id          = optional(string)
    description = optional(string)
  })

  default = {
    create = true
  }

  # Validates that if the user indicates the creation of the global network (var.global_network.create), it does not pass any id (var.global_network.id)
  validation {
    condition     = (var.global_network.create && var.global_network.id == null) || (!var.global_network.create && var.global_network.description == null)
    error_message = "If you select the creation of a new Global Network (var.global_network.create to true), you need to provide a description (var.global_network.description). If not, you need to provide an ID of a current Global Network (var.global_network.id)."
  }

  # Either var.global_network.id or var.global_network.description has to be defined
  validation {
    condition     = var.global_network.id == null || var.global_network.description == null
    error_message = "Only var.global_network.id or var.global_network.description has to be defined (not both attributes)."
  }
}

# Core Network Variables
variable "core_network" {
  description = <<-EOF
  Core Network definition. The following attributes are required:
  - `description`     = (string) Core Network's description.
  - `policy_document` = (any) Core Network's policy in JSON format. It is recommended the use of the [Core Network Document data source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/networkmanager_core_network_policy_document)
  ```
EOF
  type = object({
    description     = string
    policy_document = any
  })
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
