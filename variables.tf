# Global Network Variables
variable "global_network" {
  description = "Global Network - if the ID is not provided, the module creates it."
  type = object({
    id          = optional(string)
    description = optional(string)
  })

  validation {
    error_message = "You cannot have both Global Network's ID and name defined. Either you provide an ID (as the resource was created by you) or a Name (to create the resource)."
    condition     = length(setintersection(keys(var.global_network), ["id", "description"])) != 1
  }
}

# Core Network Variables
variable "core_network" {
  description = "Core Network information."
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
