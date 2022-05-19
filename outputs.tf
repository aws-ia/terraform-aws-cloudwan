# GLOBAL NETORK (if created)
output "global_network" {
    value = try(awscc_networkmanager_global_network.global_network, null)
    description = "Global Network information."
}

# CORE NETWORK
output "core_network" {
    value = awscc_networkmanager_core_network.core_network
    description = "Core Network information."
}