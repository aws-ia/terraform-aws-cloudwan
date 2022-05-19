# Global Network Variables
variable "global_network" {
    description = "Global Network - if the ID is not provided, the module creates it."
    type = object({
        id = optional(string)
        name = optional(string)
    })

    validation {
        error_message = "You cannot have both Global Network's ID and name defined. Either you provide an ID (as the resource was created by you) or a Name (to create the resource)."
        condition = lenght(intersection(keys(var.global_network), ["id", "name"]) == 1)
    }
}

# Core Network Variables
variable "core_network" {
    description = "Core Network information."
    type = object({
        name = string
        policy_document = any
    })
}
