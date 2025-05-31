<!-- BEGIN_TF_DOCS -->
# AWS Cloud WAN Module

This module can be used to deploy an [AWS Cloud WAN](https://docs.aws.amazon.com/vpc/latest/cloudwan/what-is-cloudwan.html) network - with the Core Network as main resource. A Global Network (the high-level container for the Core Network), can also be created if required.

In addition, the module abstracts Central VPCs' creation and Core Network attachment - with the Global Network and Core Network created either within or outside the same module definition. Central VPC types supported are Inspection, Egress (with or without inspection), Ingress (with or without inspection), and Shared Services. Below you can find more information about the format and definition of each VPC type.

## Global Network and Core Network

Two variables - `var.global_network` and `var.core_network` - are used to define the Global Network and Core Network. Starting with the **Global Network**, the following attributes can be configured:

- `description` = (string) Global Network's description.
- `tags`        = (Optional|map(string)) Tags to apply to the Global Network resource.

If a Global Network is already created and it is desired to pass only the resource ID to create a Core Network, use the `var.global_network_id` variable.

Following with the **Core Network**, the following attributes can be configured:

- `description`                              = (string) Core Network's description.
- `policy_document`                          = (any) Core Network's policy in JSON format. It is recommended the use of the [Core Network Document data source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/networkmanager_core_network_policy_document).
- `resource_share_name`                      = (Optional|string) AWS Resource Access Manager (RAM) Resource Share name. Providing this value, RAM resources will be created to share the Core Network with the principals indicated in `var.core_network.ram_share_principals`.
- `resource_share_allow_external_principals` = (Optional|bool) Indicates whether principals outside your AWS Organization can be associated with a Resource Share.
- `ram_share_principals`                     = (Optional|list(string)) List of principals (AWS Account or AWS Organization) to share the Core Network with.
- `tags`                                     = (Optional|map(string)) Tags to apply to the Core Network and RAM Resource Share (if created) resources.

If a Core Network is already created and it is desired to pass only the resource ARN to attach Central VPCs, use the `var.core_network_arn` variable.

### Examples

The example below builds an AWS Network Manager Global Network and Core Network from scratch. The Core Network needs the ID of the Global Network created, and also a policy document (to define the global infrastructure). You can find more information about the policy document in the [documentation](https://docs.aws.amazon.com/network-manager/latest/cloudwan/cloudwan-policy-change-sets.html)

```hcl
module "cloudwan" {
  source  = "aws-ia/cloudwan/aws"
  version = "3.x.x"

  global_network = {
    description = "Global Network - AWS Cloud WAN Module"

    tags = {
      Name "global-network"
    }
  }
  core_network = {
    description     = "Core Network - AWS Cloud WAN Module"
    policy_document = data.aws_networkmanager_core_network_policy_document.main.json

    tags = {
      Name = "core-network"
    }
  }

  tags = {
      Module = "aws-ia/cloudwan/aws"
  }
}
```

If you already have a Network Manager Global Network created, you can pass the ID as variable and only create the Core Network.

```hcl
module "cloudwan" {
  source  = "aws-ia/cloudwan/aws"
  version = "3.x.x"

  global_network_id "global-network-021aedd98c7487b93"

  core_network = {
    description     = "Global Network - AWS CloudWAN Module"
    policy_document = data.aws_networkmanager_core_network_policy_document.main.json
    tags = {
      Name = "core-network"
    }
  }

  tags = {
      Module = "aws-ia/cloudwan/aws"
  }
}
```

In addition, when creating a new Core Network, you can also share it using [AWS Resource Access Manager](https://docs.aws.amazon.com/ram/latest/userguide/what-is.html) (RAM). You can [share a core network](https://docs.aws.amazon.com/network-manager/latest/cloudwan/cloudwan-share-network.html) across accounts or across your organization. Important to note that **you must share your global resource from the N. Virginia (us-east-1) Region so that all other Regions can see the global resource.**

```hcl
module "cloud_wan" {
  source  = "aws-ia/cloudwan/aws"
  version = "3.x.x"

  global_network = {
    description = "Global Network - ${var.identifier}"

    tags = {
      Name = "global-network"
    }
  }

  core_network = {
    description     = "Core Network - ${var.identifier}"
    policy_document = data.aws_networkmanager_core_network_policy_document.policy.json

    resource_share_name                      = "core-network-share"
    resource_share_allow_external_principals = false
    ram_share_principals                     = [org-XXX]

    tags = {
      Name = "core-network"
    }
  }

  tags = {
    Project = var.identifier
  }
}
```

### Policy Creation

Policy documents can be passed as a string of JSON or using the [policy\_document data source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/networkmanager_core_network_policy_document) (recommended option).

```hcl
data "aws_networkmanager_core_network_policy_document" "policy" {
  core_network_configuration {
    vpn_ecmp_support = false
    asn_ranges       = ["64512-64520"]
    edge_locations {
      location = "us-east-1"
      asn      = 64512
    }
  }

  segments {
    name                          = "shared"
    description                   = "SegmentForSharedServices"
    require_attachment_acceptance = true
  }

  segment_actions {
    action     = "share"
    mode       = "attachment-route"
    segment    = "shared"
    share_with = ["*"]
  }

  attachment_policies {
    rule_number     = 1
    condition_logic = "or"

    conditions {
      type     = "tag-value"
      operator = "equals"
      key      = "segment"
      value    = "shared"
    }
    action {
      association_method = "constant"
      segment            = "shared"
    }
  }
}
```

## Network definition

The variable `var.ipv4_network_definition` is an attribute to configure a supernet (IPv4 CIDR block) or [managed prefix list](https://docs.aws.amazon.com/vpc/latest/userguide/managed-prefix-lists.html) of your network/VPCs in AWS. This variable is used when configuring VPC routing in some central VPCs. When checking the different VPC types below, you can check whether this variable is required or not.

## Central VPCs

Aside the creation of the Global Network and Core Network, this module also abstracts the creation of Central VPCs - and the attachment to the Core Network. The variable `var.central_vpcs` can be configured with a map of VPC definitions, with the following attributes:

- `type`                     = (string) VPC type (`inspection`, `egress`, `egress_with_inspection`, `ingress`, `ingress_with_inspection`, `shared_services`) - each one of them with a specific VPC routing. For more information about the configuration of each VPC type, check each Central VPC type section below.
- `name`                     = (Optional|string) Name of the VPC. If not defined, the key of the map will be used.
- `cidr_block`               = (Optional|string) IPv4 CIDR range. **Cannot set if vpc\_ipv4\_ipam\_pool\_id is set.**
- `vpc_ipv4_ipam_pool_id`    = (Optional|string) Set to use IPAM to get an IPv4 CIDR block.  **Cannot set if cidr\_block is set.**
- `vpc_ipv4_netmask_length`  = (Optional|number) Set to use IPAM to get an IPv4 CIDR block using a specified netmask. Must be set with `var.vpc_ipv4_ipam_pool_id`.
- `az_count`                 = (number) Searches the number of AZs in the region and takes a slice based on this number - the slice is sorted a-z.
- `vpc_enable_dns_hostnames` = (Optional|bool) Indicates whether the instances launched in the VPC get DNS hostnames. Enabled by default.
- `vpc_enable_dns_support`   = (Optional|bool) Indicates whether the DNS resolution is supported for the VPC. If enabled, queries to the Amazon provided DNS server at the 169.254.169.253 IP address, or the reserved IP address at the base of the VPC network range "plus two" succeed. If disabled, the Amazon provided DNS service in the VPC that resolves public DNS hostnames to IP addresses is not enabled. Enabled by default.
- `vpc_instance_tenancy`     = (Optional|string) The allowed tenancy of instances launched into the VPC.
- `vpc_flow_logs`            = (Optional|object(any)) Configuration of the VPC Flow Logs of the VPC configured. Options: "cloudwatch", "s3", "none".
- `subnets`                  = (any) Configuration of the subnets to create in the VPC - a map of subnets' definition is expected. Depending the VPC type, the format (subnets to configure and resources created by the module) will be different. Check each Central VPC type section below. for more information.
- `tags`                     = (Optional|map(string)) Tags to apply to all the Central VPC resources.

To simplify the definition of this module, the following [VPC module](https://registry.terraform.io/modules/aws-ia/vpc/aws/latest) is used to create the VPC resources. We recommend to review its README to have more information about its inputs and outputs.

### Inspection VPC

Defining the type **inspection** will create specific VPC subnets and routing to create a central Inspection VPC - specific for East/West traffic inspection. When defining the VPC subnets (attribute `subnets`) two keys are mandatory: **endpoints** - to place the [AWS Network Firewall](https://aws.amazon.com/network-firewall/) or [Gateway Load Balancer](https://aws.amazon.com/elasticloadbalancing/gateway-load-balancer/) endpoints - and **core\_network** - to place the Core Network attachment ENIs -. You are free to create additional subnets, but default configuration and VPC routing won't be created on them.

When defining the subnets, the following attributes can be configured:

- `cidrs`       = (Optional|list(string)) **Cannot set if `netmask` is set.** List of IPv4 CIDRs to set to subnets. Count of CIDRs defined must match quantity of VPC Availability Zones in `az_count`.
- `netmask`     = (Optional|number) **Cannot set if `cidrs` is set.**. Netmask of VPC CIDR block to calculate for each subnet.
- `name_prefix` = (Optional|string) A string prefix to use for the name of your subnet and associated resources. Subnet type key name is used if omitted.
- `tags`        = (Optional|map(string)) Tags to set on the subnet and associated resources. For example, for the *core\_network* subnet type, these tags will be applied to the Core Network attachment.

In addition, additional attributes can be configured for the **core\_network** subnet type:

- `appliance_mode_support`  = (Optional|bool) Indicates whether appliance mode is supported. If enabled, traffic flow between a source and destination use the same Availability Zone for the VPC attachment for the lifetime of that flow. Defaults to `true`.
- `require_acceptance`      = (Optional|bool) Whether the core network VPC attachment requires acceptance or not. Defaults to `false`.
- `accept_attachment`       = (Optional|bool) Whether the core network VPC attachment is accepted or not in the segment. Only valid if `require_acceptance` is set to `true`. Defaults to `true`.

Regarding the VPC routing, a default route (0.0.0.0/0) is created in the **endpoints** route tables pointing to the Core Network attachment.

```hcl
module "inspection_vpc" {
  source  = "aws-ia/cloudwan/aws"
  version = "3.x.x"

  core_network_arn = module.cloud_wan.core_network.arn

  central_vpcs = {
    inspection-east-west = {
      type       = "inspection"
      cidr_block = "10.10.0.0/24"
      az_count   = 2

      subnets = {
        endpoints = { cidrs = ["10.10.0.0/28", "10.10.0.16/28"] }
        core_network = {
          cidrs = ["10.10.0.32/28", "10.10.0.48/28"]

          tags = { domain = "inspection" }
        }
      }
    }
  }
}
```

### Egress VPC

Defining the type **egress** will create specific VPC subnets and routing to create a central Egress VPC. When defining the VPC subnets (attribute `subnets`) two keys are mandatory: **public** - to place the [NAT gateways](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html) or [NAT instances](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html) - and **core\_network** - to place the Core Network attachment ENIs -. You are free to create additional subnets, but default configuration and VPC routing won't be created on them.

When defining the subnets, the following attributes can be configured:

- `cidrs`       = (Optional|list(string)) **Cannot set if `netmask` is set.** List of IPv4 CIDRs to set to subnets. Count of CIDRs defined must match quantity of VPC Availability Zones in `az_count`.
- `netmask`     = (Optional|number) **Cannot set if `cidrs` is set.**. Netmask of VPC CIDR block to calculate for each subnet.
- `name_prefix` = (Optional|string) A string prefix to use for the name of your subnet and associated resources. Subnet type key name is used if omitted.
- `tags`        = (Optional|map(string)) Tags to set on the subnet and associated resources. For example, for the *core\_network* subnet type, these tags will be applied to the Core Network attachment.

In addition, additional attributes can be configured for both the **public** and **core\_network** subnet types:

- Public subnets (*public*)
  - `nat_gateway_configuration` = (Optional|string) Determines if NAT Gateways should be created and in how many AZs. Valid values = `"none"`, `"single_az"`, `"all_azs"` (default).
  - `map_public_ip_on_launch`   = (Optional|bool) Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default to `false`.
- Core Network subnets (*core\_network*)
  - `connect_to_public_natgw` = (Optional|bool) Determines if a default route to NAT Gateways should be created. Defaults to `true`.
  - `appliance_mode_support`  = (Optional|bool) Indicates whether appliance mode is supported. If enabled, traffic flow between a source and destination use the same Availability Zone for the VPC attachment for the lifetime of that flow. Defaults to `false`.
  - `require_acceptance`      = (Optional|bool) Whether the core network VPC attachment requires acceptance or not. Defaults to `false`.
  - `accept_attachment`       = (Optional|bool) Whether the core network VPC attachment is accepted or not in the segment. Only valid if `require_acceptance` is set to `true`. Defaults to `true`.

Regarding the VPC routing, the default configuration of the `connect_to_public_natgw` attribute in the **core\_network** subnet type creates a default route (0.0.0.0/0) in the route tables to the NAT gateways. The CIDR block or Prefix List defined in `var.ipv4_network_definition` (required in this VPC type) will be used to create a VPC route to the Core Network in the **public** route tables.

```hcl
module "egress_vpc" {
  source  = "aws-ia/cloudwan/aws"
  version = "3.x.x"

  core_network_arn = module.cloud_wan.core_network.arn

  ipv4_network_definition = "10.0.0.0/8"

  central_vpcs = {
    central-egress = {
      type       = "egress"
      cidr_block = "10.10.0.0/24"
      az_count   = 2

      subnets = {
        public = { cidrs = ["10.10.0.0/28", "10.10.0.16/28"] }
        core_network = {
          cidrs = ["10.10.0.32/28", "10.10.0.48/28"]

          tags = { domain = "egress" }
        }
      }
    }
  }
}
```

### Egress VPC (with inspection)

Defining the type **egress\_with\_inspection** will create specific VPC subnets and routing to create a central Egress VPC with subnets to add an inspection layer between the Core Network attachment and the public subnets - to inspect egress traffic. When defining the VPC subnets (attribute `subnets`) three keys are mandatory:

- **public** to place the [NAT gateways](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html) or [NAT instances](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html)
- **endpoints** to place the [AWS Network Firewall](https://aws.amazon.com/network-firewall/) or [Gateway Load Balancer](https://aws.amazon.com/elasticloadbalancing/gateway-load-balancer/) endpoints.
- **core\_network** to place the Core Network attachment ENIs.

You are free to create additional subnets, but default configuration and VPC routing won't be created on them. When defining the subnets, the following attributes can be configured:

- `cidrs`       = (Optional|list(string)) **Cannot set if `netmask` is set.** List of IPv4 CIDRs to set to subnets. Count of CIDRs defined must match quantity of VPC Availability Zones in `az_count`.
- `netmask`     = (Optional|number) **Cannot set if `cidrs` is set.**. Netmask of VPC CIDR block to calculate for each subnet.
- `name_prefix` = (Optional|string) A string prefix to use for the name of your subnet and associated resources. Subnet type key name is used if omitted.
- `tags`        = (Optional|map(string)) Tags to set on the subnet and associated resources. For example, for the *core\_network* subnet type, these tags will be applied to the Core Network attachment.

In addition, additional attributes can be configured for the **public**, **endpoints**, and **core\_network** subnet types:

- Public subnets (*public*)
  - `nat_gateway_configuration` = (Optional|string) Determines if NAT Gateways should be created and in how many AZs. Valid values = `"none"`, `"single_az"`, `"all_azs"` (default).
  - `map_public_ip_on_launch`   = (Optional|bool) Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default to `false`.
- Endpoint subnets (*endpoints*)
  - `connect_to_public_natgw` = (Optional|bool) Determines if routes to NAT Gateways should be created. Defaults to `true`.
- Core Network subnets (*core\_network*)
  - `appliance_mode_support`  = (Optional|bool) Indicates whether appliance mode is supported. If enabled, traffic flow between a source and destination use the same Availability Zone for the VPC attachment for the lifetime of that flow. Defaults to `true`.
  - `require_acceptance`      = (Optional|bool) Whether the core network VPC attachment requires acceptance or not. Defaults to `false`.
  - `accept_attachment`       = (Optional|bool) Whether the core network VPC attachment is accepted or not in the segment. Only valid if `require_acceptance` is set to `true`. Defaults to `true`.

Regarding the VPC routing, the default configuration of the `connect_to_public_natgw` attribute in the **endpoints** subnet type creates a default route (0.0.0.0/0) in the route tables to the NAT gateways. The CIDR block or Prefix List defined in `var.ipv4_network_definition` (required in this VPC type) will be used to create a VPC route to the Core Network from the **endpoints** route tables.

```hcl
module "egress_with_inspection_vpc" {
  source  = "aws-ia/cloudwan/aws"
  version = "3.x.x"

  core_network_arn = module.cloud_wan.core_network.arn

  ipv4_network_definition = "10.0.0.0/8"

  central_vpcs = {
    central-egress-inspection = {
      type       = "egress_with_inspection"
      cidr_block = "10.10.0.0/24"
      az_count   = 2

      subnets = {
        public    = { netmask = 28 }
        endpoints = { netmask = 28 }
        core_network = {
          netmask = 28

          tags = { domain = "egress" }
        }
      }
    }
  }
}
```

### Ingress VPC

Defining the type **ingress** will create specific VPC subnets and routing to create a central Ingress VPC. When defining the VPC subnets (attribute `subnets`) two keys are mandatory: **public** - to place the [Elastic Load Balancers](https://aws.amazon.com/elasticloadbalancing/) or your own ingress solution - and **core\_network** - to place the Core Network attachment ENIs -. You are free to create additional subnets, but default configuration and VPC routing won't be created on them.

When defining the subnets, the following attributes can be configured:

- `cidrs`       = (Optional|list(string)) **Cannot set if `netmask` is set.** List of IPv4 CIDRs to set to subnets. Count of CIDRs defined must match quantity of VPC Availability Zones in `az_count`.
- `netmask`     = (Optional|number) **Cannot set if `cidrs` is set.**. Netmask of VPC CIDR block to calculate for each subnet.
- `name_prefix` = (Optional|string) A string prefix to use for the name of your subnet and associated resources. Subnet type key name is used if omitted.
- `tags`        = (Optional|map(string)) Tags to set on the subnet and associated resources. For example, for the *core\_network* subnet type, these tags will be applied to the Core Network attachment.

In addition, additional attributes can be configured for both the **public** and **core\_network** subnet types:

- Public subnets (*public*)
  - `connect_to_igw`          = (Optional|bool) Determines if the default route (0.0.0.0/0) is created in the public subnets with destination the Internet gateway. Defaults to `true`.
  - `map_public_ip_on_launch` = (Optional|bool) Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default to `false`.
- Core Network subnets (*core\_network*)
  - `appliance_mode_support`  = (Optional|bool) Indicates whether appliance mode is supported. If enabled, traffic flow between a source and destination use the same Availability Zone for the VPC attachment for the lifetime of that flow. Defaults to `false`.
  - `require_acceptance`      = (Optional|bool) Whether the core network VPC attachment requires acceptance or not. Defaults to `false`.
  - `accept_attachment`       = (Optional|bool) Whether the core network VPC attachment is accepted or not in the segment. Only valid if `require_acceptance` is set to `true`. Defaults to `true`.

Regarding the VPC routing, the CIDR block or Prefix List defined in `var.ipv4_network_definition` (required in this VPC type) will be used to create a VPC route to the Core Network in the **public** route tables.

```hcl
module "egress_with_inspection_vpc" {
  source  = "aws-ia/cloudwan/aws"
  version = "3.x.x"

  core_network_arn = module.cloud_wan.core_network.arn

  ipv4_network_definition = "10.0.0.0/8"

  central_vpcs = {
    ingress = {
      type       = "ingress"
      cidr_block = "10.10.0.0/24"
      az_count   = 2

      subnets = {
        public = { netmask = 28 }
        core_network = {
          netmask = 28

          tags = { domain = "ingress" }
        }
      }
    }
  }
}
```

### Ingress VPC (with inspection)

Defining the type **ingress\_with\_inspection** will create specific VPC subnets and routing to create a central Ingress VPC with subnets to add an inspection layer between the Internet gateway and the public subnets - to inspect ingress traffic. When defining the VPC subnets (attribute `subnets`) three keys are mandatory:

- **endpoints** to place the [AWS Network Firewall](https://aws.amazon.com/network-firewall/) or [Gateway Load Balancer](https://aws.amazon.com/elasticloadbalancing/gateway-load-balancer/) endpoints.
- **public** to place the [Elastic Load Balancers](https://aws.amazon.com/elasticloadbalancing/) or your own ingress solution.
- **core\_network** to place the Core Network attachment ENIs.

You are free to create additional subnets, but default configuration and VPC routing won't be created on them. When defining the subnets, the following attributes can be configured:

- `cidrs`       = (Optional|list(string)) **Cannot set if `netmask` is set.** List of IPv4 CIDRs to set to subnets. Count of CIDRs defined must match quantity of VPC Availability Zones in `az_count`.
- `netmask`     = (Optional|number) **Cannot set if `cidrs` is set.**. Netmask of VPC CIDR block to calculate for each subnet.
- `name_prefix` = (Optional|string) A string prefix to use for the name of your subnet and associated resources. Subnet type key name is used if omitted.
- `tags`        = (Optional|map(string)) Tags to set on the subnet and associated resources. For example, for the *core\_network* subnet type, these tags will be applied to the Core Network attachment.

In addition, additional attributes can be configured for both the **public** and **core\_network** subnet types:

- Public subnets (*public*)
  - `connect_to_igw`          = (Optional|bool) Determines if the default route (0.0.0.0/0) is created in the public subnets with destination the Internet gateway. Defaults to `false`.
  - `map_public_ip_on_launch` = (Optional|bool) Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default to `false`.
- Core Network subnets (*core\_network*)
  - `appliance_mode_support`  = (Optional|bool) Indicates whether appliance mode is supported. If enabled, traffic flow between a source and destination use the same Availability Zone for the VPC attachment for the lifetime of that flow. Defaults to `false`.
  - `require_acceptance`      = (Optional|bool) Whether the core network VPC attachment requires acceptance or not. Defaults to `false`.
  - `accept_attachment`       = (Optional|bool) Whether the core network VPC attachment is accepted or not in the segment. Only valid if `require_acceptance` is set to `true`. Defaults to `true`.

Regarding the VPC routing, the CIDR block or Prefix List defined in `var.ipv4_network_definition` (required in this VPC type) will be used to create a VPC route to the Core Network in the **public** route tables.

```hcl
module "egress_with_inspection_vpc" {
  source  = "aws-ia/cloudwan/aws"
  version = "3.x.x"

  core_network_arn = module.cloud_wan.core_network.arn

  ipv4_network_definition = "10.0.0.0/8"

  central_vpcs = {
    ingress-with-inspection = {
      type       = "ingress_with_inspection"
      cidr_block = "10.10.0.0/24"
      az_count   = 2

      subnets = {
        endpoints = { netmask = 28 }
        public    = { netmask = 28 }
        core_network = {
          netmask = 28

          tags = { domain = "ingress" }
        }
      }
    }
  }
}
```

### Shared Services VPC

Defining the type **shared\_services** will create specific VPC subnets and routing to create a central Shared Services VPC. When defining the VPC subnets (attribute `subnets`) the only mandatory key is **core\_network** - to place the Core Network attachment ENIs. When defining the subnets, the following attributes can be configured:

- `cidrs`       = (Optional|list(string)) **Cannot set if `netmask` is set.** List of IPv4 CIDRs to set to subnets. Count of CIDRs defined must match quantity of VPC Availability Zones in `az_count`.
- `netmask`     = (Optional|number) **Cannot set if `cidrs` is set.**. Netmask of VPC CIDR block to calculate for each subnet.
- `name_prefix` = (Optional|string) A string prefix to use for the name of your subnet and associated resources. Subnet type key name is used if omitted.
- `tags`        = (Optional|map(string)) Tags to set on the subnet and associated resources. For example, for the *core\_network* subnet type, these tags will be applied to the Core Network attachment.

In addition, additional attributes can be configured for both the **core\_network** subnet type:

- `appliance_mode_support`  = (Optional|bool) Indicates whether appliance mode is supported. If enabled, traffic flow between a source and destination use the same Availability Zone for the VPC attachment for the lifetime of that flow. Defaults to `false`.
- `require_acceptance`      = (Optional|bool) Whether the core network VPC attachment requires acceptance or not. Defaults to `false`.
- `accept_attachment`       = (Optional|bool) Whether the core network VPC attachment is accepted or not in the segment. Only valid if `require_acceptance` is set to `true`. Defaults to `true`.

Regarding the VPC routing, a default route (0.0.0.0/0) poiting to the Core Network attachment will be created in any private route table you create.

```hcl
module "egress_with_inspection_vpc" {
  source  = "aws-ia/cloudwan/aws"
  version = "3.x.x"

  core_network_arn = module.cloud_wan.core_network.arn

  central_vpcs = {
    shared-services = {
      type       = "shared_services"
      cidr_block = "10.10.0.0/24"
      az_count   = 2

      subnets = {
        vpc_endpoints = { netmask = 28 }
        hybrid_dns    = { netmask = 28 }
        core_network = {
          netmask = 28

          tags = { domain = "shared" }
        }
      }
    }
  }
}
```

## AWS Network Firewall

The variable `var.aws_network_firewall` allows the configuration of [AWS Network Firewall](https://aws.amazon.com/network-firewall/) resources in those central VPCs where inspection can be added - VPC types `inspection`, `egress_with_inspection` and `ingress_with_inspection`. As we use the following [AWS Network Firewall module](https://registry.terraform.io/modules/aws-ia/networkfirewall/aws/latest), the VPC routing pointing to the firewall endpoints is also abstracted.

The variable expects a map containing the Network Firewall configuration to apply in each VPC. How do you make sure the Network Firewall resource (and VPC routing) is created in the corresponding central VPC? By using the same **key value** you used in `var.central_vpcs`. Each map definition expects the following attributes:

- `name`                     = (string) Name of the AWS Network Firewall resource.
- `description`              = (string) Description of the AWS Network Firewall resource.
- `policy_arn`               = (string) ARN of the Network Firewall Policy.
- `delete_protection`        = (Optional|bool) Indicates whether it is possible to delete the firewall. Defaults to `false`.
- `policy_change_protection` = (Optional|bool) Indicates whether it is possible to change the firewall policy. Defaults to `false`.
- `subnet_change_protection` = (Optional|bool) Indicates whether it is possible to change the associated subnet(s) after creation. Defaults to `false`.
- `tags`                     = (Optional|map(string)) Tags to apply to the AWS Network Firewall resource.

### Inspection VPC

If you configure the creation of an AWS Network Firewall resource in an Inspection VPC (type `inspection`), the VPC routes created are the default ones (0.0.0.0/0) pointing to the firewall endpoints in the **core\_network** route tables.

```hcl
module "cloudwan_central_vpcs" {
  source  = "aws-ia/cloudwan/aws"
  version = "3.x.x"

  global_network = {
    description = "Global Network"

    tags = {
      Name = "global-network"
    }
  }

  core_network = {
    description     = "Core Network"
    policy_document = data.aws_networkmanager_core_network_policy_document.policy.json

    tags = {
      Name = "core-network"
    }
  }

  ipv4_network_definition = "10.0.0.0/8"
  central_vpcs = {
    inspection = {
      type       = "inspection"
      cidr_block = "10.10.0.0/24"
      az_count   = 2

      subnets = {
        endpoints = { netmask = 28 }
        core_network = {
          netmask = 28

          tags = { domain = "inspection" }
        }
      }
    }
  }

  aws_network_firewall = {
    inspection = {
      name        = "anfw-inspection"
      description = "AWS Network Firewall - East/West"
      policy_arn  = aws_networkfirewall_firewall_policy.policy.arn
    }
  }
}
```

### Egress VPC

If you configure the creation of an AWS Network Firewall resource in an Egress VPC (type `egress_with_inspection`), the VPC routes created are:

* Default route (0.0.0.0/0) pointing to the firewall endpoints in the **core\_network** route tables.
* CIDR blocks provided in `var.ipv4_network_definition` pointing to the firewall endpoints in the **public** route tables.

```hcl
module "cloudwan_central_vpcs" {
  source  = "aws-ia/cloudwan/aws"
  version = "3.x.x"

  global_network = {
    description = "Global Network"

    tags = {
      Name = "global-network"
    }
  }

  core_network = {
    description     = "Core Network"
    policy_document = data.aws_networkmanager_core_network_policy_document.policy.json

    tags = {
      Name = "core-network"
    }
  }

  ipv4_network_definition = "10.0.0.0/8"
  central_vpcs = {
    egress-inspection = {
      type       = "egress_with_inspection"
      cidr_block = "10.10.0.0/24"
      az_count   = 2

      subnets = {
        public    = { netmask = 28 }
        endpoints = { netmask = 28 }
        core_network = {
          netmask = 28

          tags = { domain = "egress" }
        }
      }
    }
  }

  aws_network_firewall = {
    egress-inspection = {
      name        = "anfw-egress-inspection"
      description = "AWS Network Firewall - Egress"
      policy_arn  = aws_networkfirewall_firewall_policy.policy.arn
    }
  }
}
```

### Ingress VPC

If you configure the creation of an AWS Network Firewall resource in an Ingress VPC (type `ingress_with_inspection`), the following resources are created:

* VPC route table associated to the Internet gateway.
* Public subnet CIDR blocks pointing to the firewall endpoints in the IGW route table.
* Default route (0.0.0.0/0) pointing to the firewall endpoints in the **public** route tables.

```hcl
module "cloudwan_central_vpcs" {
  source  = "aws-ia/cloudwan/aws"
  version = "3.x.x"

  global_network = {
    description = "Global Network"

    tags = {
      Name = "global-network"
    }
  }

  core_network = {
    description     = "Core Network"
    policy_document = data.aws_networkmanager_core_network_policy_document.policy.json

    tags = {
      Name = "core-network"
    }
  }

  ipv4_network_definition = "10.0.0.0/8"
  central_vpcs = {
    ingress-inspection = {
      type       = "ingress_with_inspection"
      cidr_block = "10.10.0.0/24"
      az_count   = 2

      subnets = {
        endpoints = { netmask = 28 }
        public    = { netmask = 28 }
        core_network = {
          netmask = 28

          tags = { domain = "ingress" }
        }
      }
    }
  }

  aws_network_firewall = {
    ingress-inspection = {
      name        = "anfw-ingress-inspection"
      description = "AWS Network Firewall - Ingress"
      policy_arn  = aws_networkfirewall_firewall_policy.policy.arn
    }
  }
}
```

## Common questions

### How can I configure tags in the Core Network attachment?

AWS Cloud WAN automates the association of an attachment to a specific segment, reducing the operational overhead specially in multi-Account environments. If you check how to define a [core network policy](https://docs.aws.amazon.com/network-manager/latest/cloudwan/cloudwan-policies-json.html), you will see that the parameter **attachment-policies** is where you can define how to automate the associations. What can you use to define the attachment's association policy? You can use the Resource ID, Account ID, AWS Region, Attachment Type, and **Tags** - which is the common item to use.

Now that we have explained the importance of tags when creating Core Network attachments, how can I create these tags using the module? As we use the following [VPC module](https://registry.terraform.io/modules/aws-ia/vpc/aws/latest) to create the central VPCs, the tags defined under the **core\_network** subnet type will be applied to the Core Network attachment.

```hcl
core_network = {
  netmask = 28

  tags = { domain = "segment" }
}
```

### Should I create Central VPCs in the same module definition as the Core Network?

This module has been created to be used once per AWS Region you are creating resources - only 1 provider can be configured. This means that, if you want to create Central VPCs in several AWS Regions, you should have 1 module definition per Region. What about the Global Network and Core Network? These resources are global, and they can be created using a provider definition from any Region - of course, where [Cloud WAN is available](https://docs.aws.amazon.com/network-manager/latest/cloudwan/what-is-cloudwan.html#cloudwan-available-regions). **Important to note that whatever Region you configure for the provider that creates the Cloud WAN resources, the [home region](https://docs.aws.amazon.com/network-manager/latest/cloudwan/what-is-cloudwan.html#cloudwan-home-region) will be US West (Oregon)**.

Coming back to the question, our recommendation is to create the Global Network and Core Network in a different module definition than the Central VPCs - even if the provider you use to create the global resource is also used to create Central VPCs in that same Region. The main reason of the recommendation is to decouple the definition of global and regional resources. That said, if you want to use the same module definition to create global resources and central VPCs in the Region the provider has configured, the module will allow you to do it (and it's not an anti-pattern).

## Troubleshooting

### Creating Central VPCs with IPAM configuration - The "for\_each" map includes keys derived from resource attributes that cannot be determined until apply

When creating Central VPCs referencing an IPAM pool ID, you get the following error:

```
The "for_each" map includes keys derived from resource attributes that cannot be determined until apply, and so Terraform cannot determine the full set of keys that will identify the instances of this resource.
When working with unknown values in for_each, it's better to define the map keys statically in your configuration and place apply-time results only in the map values.
Alternatively, you could use the -target planning option to first apply only the resources that the for_each value depends on, and then apply a second time to fully converge.
```

As described in the error itself, you first need to create the IPAM pool to then later create the VPCs. You can use the [target](https://developer.hashicorp.com/terraform/tutorials/state/resource-targeting) option if the IPAM resources are created in the same document (and state file) as the VPCs.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.21.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.21.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_central_vpcs"></a> [central\_vpcs](#module\_central\_vpcs) | aws-ia/vpc/aws | 4.4.4 |
| <a name="module_core_network_tags"></a> [core\_network\_tags](#module\_core\_network\_tags) | aws-ia/label/aws | 0.0.6 |
| <a name="module_global_network_tags"></a> [global\_network\_tags](#module\_global\_network\_tags) | aws-ia/label/aws | 0.0.6 |
| <a name="module_network_firewall"></a> [network\_firewall](#module\_network\_firewall) | aws-ia/networkfirewall/aws | 1.0.2 |
| <a name="module_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#module\_public\_subnet\_cidrs) | ./modules/subnet_cidrs | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | aws-ia/label/aws | 0.0.6 |

## Resources

| Name | Type |
|------|------|
| [aws_networkmanager_core_network.core_network](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkmanager_core_network) | resource |
| [aws_networkmanager_core_network_policy_attachment.policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkmanager_core_network_policy_attachment) | resource |
| [aws_networkmanager_global_network.global_network](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkmanager_global_network) | resource |
| [aws_ram_principal_association.principal_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_resource_association.resource_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_share.resource_share](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |
| [aws_route_table.igw_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.igw_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_prefix_list.ipv4_network_definition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/prefix_list) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_network_firewall"></a> [aws\_network\_firewall](#input\_aws\_network\_firewall) | AWS Network Firewall configuration. This variable expect a map of Network Firewall definitions to create a firewall resource (and corresponding VPC routing to firewall endpoints) in the corresponding VPC. The central VPC to create the resources is specified by using the same map key as in var.central\_vpcs. Resources will be created only in VPC types `inspection`, `egress_with_inspection`, and `ingress_with_inspection`.<br/>Each map item expects the following attributes:<br/>- `name`                     = (string) Name of the AWS Network Firewall resource.<br/>- `description`              = (string) Description of the AWS Network Firewall resource.<br/>- `policy_arn`               = (string) ARN of the Network Firewall Policy.<br/>- `delete_protection`        = (Optional\|bool) Indicates whether it is possible to delete the firewall. Defaults to `false`.<br/>- `policy_change_protection` = (Optional\|bool) Indicates whether it is possible to change the firewall policy. Defaults to `false`.<br/>- `subnet_change_protection` = (Optional\|bool) Indicates whether it is possible to change the associated subnet(s) after creation. Defaults to `false`.<br/>- `tags`                     = (Optional\|map(string)) Tags to apply to the AWS Network Firewall resource. | `any` | `{}` | no |
| <a name="input_central_vpcs"></a> [central\_vpcs](#input\_central\_vpcs) | Central VPCs definition. This variable expects a map of VPCs. You can specify the following attributes:<br/>- `type`                     = (string) VPC type (`inspection`, `egress`, `egress_with_inspection`, `ingress`, `ingress_with_inspection`, `shared_services`) - each one of them with a specific VPC routing. For more information about the configuration of each VPC type, check the README.<br/>- `name`                     = (Optional\|string) Name of the VPC. If not defined, the key of the map will be used.<br/>- `cidr_block`               = (Optional\|string) IPv4 CIDR range. **Cannot set if vpc\_ipv4\_ipam\_pool\_id is set.**<br/>- `vpc_ipv4_ipam_pool_id`    = (Optional\|string) Set to use IPAM to get an IPv4 CIDR block.  **Cannot set if cidr\_block is set.**<br/>- `vpc_ipv4_netmask_length`  = (Optional\|number) Set to use IPAM to get an IPv4 CIDR block using a specified netmask. Must be set with `var.vpc_ipv4_ipam_pool_id`.<br/>- `az_count`                 = (number) Searches the number of AZs in the region and takes a slice based on this number - the slice is sorted a-z.<br/>- `vpc_enable_dns_hostnames` = (Optional\|bool) Indicates whether the instances launched in the VPC get DNS hostnames. Enabled by default.<br/>- `vpc_enable_dns_support`   = (Optional\|bool) Indicates whether the DNS resolution is supported for the VPC. If enabled, queries to the Amazon provided DNS server at the 169.254.169.253 IP address, or the reserved IP address at the base of the VPC network range "plus two" succeed. If disabled, the Amazon provided DNS service in the VPC that resolves public DNS hostnames to IP addresses is not enabled. Enabled by default.<br/>- `vpc_instance_tenancy`     = (Optional\|string) The allowed tenancy of instances launched into the VPC.<br/>- `vpc_flow_logs`            = (Optional\|object(any)) Configuration of the VPC Flow Logs of the VPC configured. Options: "cloudwatch", "s3", "none".<br/>- `subnets`                  = (any) Configuration of the subnets to create in the VPC. Depending the VPC type, the format (subnets to configure and resources created by the module) will be different. Check the README for more information. <br/>- `tags`                     = (Optional\|map(string)) Tags to apply to all the Central VPC resources. | `any` | `{}` | no |
| <a name="input_core_network"></a> [core\_network](#input\_core\_network) | Core Network definition - providing information to this variable will create a new Core Network. Conflicts with `var.core_network_arn`.<br/>This variable expects the following attributes:<br/>- `description`                              = (string) Core Network's description.<br/>- `policy_document`                          = (any) Core Network's policy in JSON format.<br/>- `resource_share_name`                      = (Optional\|string) AWS Resource Access Manager (RAM) Resource Share name. Providing this value, RAM resources will be created to share the Core Network with the principals indicated in `var.core_network.ram_share_principals`.<br/>- `resource_share_allow_external_principals` = (Optional\|bool) Indicates whether principals outside your AWS Organization can be associated with a Resource Share.<br/>- `ram_share_principals`                     = (Optional\|list(string)) List of principals (AWS Account or AWS Organization) to share the Core Network with.<br/>- `tags`                                     = (Optional\|map(string)) Tags to apply to the Core Network and RAM Resource Share (if created). | `any` | `{}` | no |
| <a name="input_core_network_arn"></a> [core\_network\_arn](#input\_core\_network\_arn) | (Optional) Core Network ARN. Conflicts with `var.core_network`. | `string` | `null` | no |
| <a name="input_global_network"></a> [global\_network](#input\_global\_network) | Global Network definition - providing information to this variable will create a new Global Network. Conflicts with `var.global_network_id`.<br/>This variable expects the following attributes:<br/>- `description` = (string) Global Network's description.<br/>- `tags`        = (Optional\|map(string)) Tags to apply to the Global Network. | `any` | `{}` | no |
| <a name="input_global_network_id"></a> [global\_network\_id](#input\_global\_network\_id) | (Optional) Global Network ID. Conflicts with `var.global_network`. | `string` | `null` | no |
| <a name="input_ipv4_network_definition"></a> [ipv4\_network\_definition](#input\_ipv4\_network\_definition) | Definition of the IPv4 CIDR blocks of the AWS network - needed for the VPC routes in Ingress and Egress VPC types. You can specific either a CIDR range or a Prefix List ID. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_network_firewall"></a> [aws\_network\_firewall](#output\_aws\_network\_firewall) | AWS Network Firewall. Full output of aws\_networkfirewall\_firewall. |
| <a name="output_central_vpcs"></a> [central\_vpcs](#output\_central\_vpcs) | Central VPC information. Full output of VPC module - https://registry.terraform.io/modules/aws-ia/vpc/aws/latest. |
| <a name="output_core_network"></a> [core\_network](#output\_core\_network) | Core Network. Full output of aws\_networkmanager\_core\_network. |
| <a name="output_global_network"></a> [global\_network](#output\_global\_network) | Global Network. Full output of aws\_networkmanager\_global\_network. |
| <a name="output_ram_resource_share"></a> [ram\_resource\_share](#output\_ram\_resource\_share) | Resource Access Manager (RAM) Resource Share. Full output of aws\_ram\_resource\_share. |
<!-- END_TF_DOCS -->