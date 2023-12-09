# --- root/variables.tf ---

# ---------- GLOBAL NETWORK ---------
variable "global_network_id" {
  type        = string
  description = "(Optional) Global Network ID. Conflicts with `var.global_network`."
  default     = null
}

variable "global_network" {
  description = <<-EOF
    Global Network definition - providing information to this variable will create a new Global Network. Conflicts with `var.global_network_id`.
    This variable expects the following attributes:
    - `description` = (Optional|string) Global Network's description.
    - `tags`        = (Optional|map(string)) Tags to apply to the Global Network.
    ```
EOF
  type        = any
  default     = {}

  validation {
    error_message = "Only valid key values for var.global_network: \"description\", \"tags\"."
    condition = length(setsubtract(keys(var.global_network), [
      "description",
      "tags"
    ])) == 0
  }
}

# ---------- CORE NETWORK ----------
variable "core_network_arn" {
  type        = string
  description = "(Optional) Core Network ARN. Conflicts with `var.core_network`."
  default     = null
}

variable "core_network" {
  description = <<-EOF
    Core Network definition - providing information to this variable will create a new Core Network. Conflicts with `var.core_network_arn`.
    This variable expects the following attributes:
    - `description`                              = (Optional|string) Core Network's description.
    - `policy_document`                          = (Optional|any) Core Network's policy in JSON format. It is recommended the use of the [Core Network Document data source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/networkmanager_core_network_policy_document)
    - `base_policy_document`                     = (Optional|any) Conflicts with `base_policy_regions`. Sets the base policy document for the Core Network. For more information about the need of the base policy, check the README document.
    - `base_policy_regions`                      = (Optional|list(string)) Conflicts with `base_policy_document`. List of AWS Regions to create the base policy document in the Core Network. For more information about the need of the base policy, check the README document.
    - `resource_share_name`                      = (Optional|string) AWS Resource Access Manager (RAM) Resource Share name. Providing this value, RAM resources will be created to share the Core Network with the principals indicated in `var.core_network.ram_share_principals`.
    - `resource_share_allow_external_principals` = (Optional|bool) Indicates whether principals outside your AWS Organization can be associated with a Resource Share.
    - `ram_share_principals`                     = (Optional|list(string)) List of principals (AWS Account or AWS Organization) to share the Core Network with.
    - `tags`                                     = (Optional|map(string)) Tags to apply to the Core Network and RAM Resource Share (if created).
EOF
  type        = any
  default     = {}

  validation {
    error_message = "Only valid key values for var.core_network: \"description\", \"policy_document\", \"base_policy_document\", \"base_policy_regions\", \"resource_share_name\", \"resource_share_allow_external_principals\", \"ram_share_principals\", \"tags\"."
    condition = length(setsubtract(keys(var.core_network), [
      "description",
      "policy_document",
      "base_policy_document",
      "base_policy_regions",
      "resource_share_name",
      "resource_share_allow_external_principals",
      "ram_share_principals",
      "tags"
    ])) == 0
  }
}

# ---------- TAGS ----------
variable "tags" {
  description = "(Optional) Tags to apply to all resources."
  type        = map(string)

  default = {}
}
