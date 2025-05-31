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
    - `description` = (string) Global Network's description.
    - `tags`        = (Optional|map(string)) Tags to apply to the Global Network.
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
    - `description`                              = (string) Core Network's description.
    - `policy_document`                          = (any) Core Network's policy in JSON format.
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
      "resource_share_name",
      "resource_share_allow_external_principals",
      "ram_share_principals",
      "tags"
    ])) == 0
  }
}

# ---------- CENTRAL VPCS ----------
variable "central_vpcs" {
  description = <<-EOF
    Central VPCs definition. This variable expects a map of VPCs. You can specify the following attributes:
    - `type`                     = (string) VPC type (`inspection`, `egress`, `egress_with_inspection`, `ingress`, `ingress_with_inspection`, `shared_services`) - each one of them with a specific VPC routing. For more information about the configuration of each VPC type, check the README.
    - `name`                     = (Optional|string) Name of the VPC. If not defined, the key of the map will be used.
    - `cidr_block`               = (Optional|string) IPv4 CIDR range. **Cannot set if vpc_ipv4_ipam_pool_id is set.**
    - `vpc_ipv4_ipam_pool_id`    = (Optional|string) Set to use IPAM to get an IPv4 CIDR block.  **Cannot set if cidr_block is set.**
    - `vpc_ipv4_netmask_length`  = (Optional|number) Set to use IPAM to get an IPv4 CIDR block using a specified netmask. Must be set with `var.vpc_ipv4_ipam_pool_id`.
    - `az_count`                 = (number) Searches the number of AZs in the region and takes a slice based on this number - the slice is sorted a-z.
    - `vpc_enable_dns_hostnames` = (Optional|bool) Indicates whether the instances launched in the VPC get DNS hostnames. Enabled by default.
    - `vpc_enable_dns_support`   = (Optional|bool) Indicates whether the DNS resolution is supported for the VPC. If enabled, queries to the Amazon provided DNS server at the 169.254.169.253 IP address, or the reserved IP address at the base of the VPC network range "plus two" succeed. If disabled, the Amazon provided DNS service in the VPC that resolves public DNS hostnames to IP addresses is not enabled. Enabled by default.
    - `vpc_instance_tenancy`     = (Optional|string) The allowed tenancy of instances launched into the VPC.
    - `vpc_flow_logs`            = (Optional|object(any)) Configuration of the VPC Flow Logs of the VPC configured. Options: "cloudwatch", "s3", "none".
    - `subnets`                  = (any) Configuration of the subnets to create in the VPC. Depending the VPC type, the format (subnets to configure and resources created by the module) will be different. Check the README for more information. 
    - `tags`                     = (Optional|map(string)) Tags to apply to all the Central VPC resources.
EOF
  type        = any
  default     = {}

  # Key values for Central VPCs
  validation {
    error_message = "Valid key values for Central VPCs: \"type\", \"name\", \"cidr_block\", \"az_count\", \"vpc_ipv4_ipam_pool_id\", \"vpc_ipv4_netmask_length\", \"vpc_enable_dns_hostnames\", \"vpc_enable_dns_support\", \"vpc_instance_tenancy\", \"subnets\", \"vpc_flow_logs\", \"tags\"."
    condition = alltrue([
      for vpc in try(var.central_vpcs, {}) : length(setsubtract(keys(vpc), [
        "type",
        "name",
        "cidr_block",
        "az_count",
        "vpc_ipv4_ipam_pool_id",
        "vpc_ipv4_netmask_length",
        "vpc_enable_dns_hostnames",
        "vpc_enable_dns_support",
        "vpc_instance_tenancy",
        "vpc_flow_logs",
        "subnets",
        "tags"
      ])) == 0
    ])
  }

  # Valid VPC types
  validation {
    error_message = "Central VPC type can only be: \"egress\", \"inspection\", \"inspection_egress\", \"shared_services\", \"ingress\", \"inspection_ingress\"."
    condition = alltrue([
      for vpc in try(var.central_vpcs, {}) : contains(["inspection", "egress", "egress_with_inspection", "shared_services", "ingress", "ingress_with_inspection"], vpc.type)
    ])
  }
}

# ---------- NETWORK DEFINITION (IPV4) ----------
variable "ipv4_network_definition" {
  type        = string
  description = "Definition of the IPv4 CIDR blocks of the AWS network - needed for the VPC routes in Ingress and Egress VPC types. You can specific either a CIDR range or a Prefix List ID."

  default = null
}

# ---------- AWS NETWORK FIREWALL ----------
variable "aws_network_firewall" {
  description = <<-EOF
    AWS Network Firewall configuration. This variable expect a map of Network Firewall definitions to create a firewall resource (and corresponding VPC routing to firewall endpoints) in the corresponding VPC. The central VPC to create the resources is specified by using the same map key as in var.central_vpcs. Resources will be created only in VPC types `inspection`, `egress_with_inspection`, and `ingress_with_inspection`.
    Each map item expects the following attributes:
    - `name`                     = (string) Name of the AWS Network Firewall resource.
    - `description`              = (string) Description of the AWS Network Firewall resource.
    - `policy_arn`               = (string) ARN of the Network Firewall Policy.
    - `delete_protection`        = (Optional|bool) Indicates whether it is possible to delete the firewall. Defaults to `false`.
    - `policy_change_protection` = (Optional|bool) Indicates whether it is possible to change the firewall policy. Defaults to `false`.
    - `subnet_change_protection` = (Optional|bool) Indicates whether it is possible to change the associated subnet(s) after creation. Defaults to `false`.
    - `tags`                     = (Optional|map(string)) Tags to apply to the AWS Network Firewall resource.
EOF
  type        = any
  default     = {}

  # Key values for AWS Network Firewall definitions
  validation {
    error_message = "Valid key values each AWS Network Firewall definition: \"name\", \"description\", \"policy_arn\", \"delete_protection\", \"policy_change_protection\", \"subnet_change_protection\", \"tags\"."
    condition = alltrue([
      for vpc in try(var.aws_network_firewall, {}) : length(setsubtract(keys(vpc), [
        "name",
        "description",
        "policy_arn",
        "delete_protection",
        "policy_change_protection",
        "subnet_change_protection",
        "tags"
      ])) == 0
    ])
  }
}

# ---------- TAGS ----------
variable "tags" {
  description = "(Optional) Tags to apply to all resources."
  type        = map(string)

  default = {}
}
