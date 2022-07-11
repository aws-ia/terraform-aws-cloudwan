<!-- BEGIN_TF_DOCS -->
# AWS Cloud WAN Module

This module can be used to deploy an [AWS Cloud WAN](https://docs.aws.amazon.com/vpc/latest/cloudwan/what-is-cloudwan.html) Core Network using the [Terraform AWS Cloud Control Provider](https://github.com/hashicorp/terraform-provider-awscc). A Core Network is built inside a Global Network, so if that resources is not provided, it is also created. [Here is a guide](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/using-aws-with-awscc-provider) for using the resources together to create a core network.

## Usage

The example below builds a Network Manager Global Network and a Cloud WAN Core Network from scratch. The Core Network needs the ID of the Global Network created, and also a policy document (to define the global infrastructure). An example of a policy document can be found [here](https://github.com/aws-ia/terraform-aws-cloudwan/blob/61f2261fc753dca2317b7c8b3973180894d8876e/examples/with_globalnetwork/main.tf#L29-L67).

```hcl
module "cloudwan" {
  source = "aws-ia/cloudwan"

  global_network = {
    description = "Global Network - AWS CloudWAN Module"
  }
  core_network = {
    description            = "Core Network - AWS CloudWAN Module"
    policy_document        = data.aws_networkmanager_core_network_policy_document.main.json
  }

  tags = {
      Name = "create-global-network"
  }
}
```

If you already have a Network Manager Global Network created, you can pass the ID as variable and only create the Cloud Wan Core Network.

```hcl
module "cloudwan" {
  source = "aws-ia/cloudwan"

  global_network = {
    id = "global-network-021aedd98c7487b93"
  }
  core_network = {
    description            = "Global Network - AWS CloudWAN Module"
    policy_document        = data.aws_networkmanager_core_network_policy_document.main.json
  }

  tags = {
      Name = "reference-preexisting-global-network"
  }
}
```

## Policy Creation

Policy documents can be passed as a string of JSON or using the [policy\_document data source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/networkmanager_core_network_policy_document)

```terraform
data "aws_networkmanager_core_network_policy_document" "main" {
  core_network_configuration {
    vpn_ecmp_support = false
    asn_ranges       = ["64512-64555"]
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

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.21.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | >= 0.21.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_tags"></a> [tags](#module\_tags) | aws-ia/label/aws | 0.0.5 |

## Resources

| Name | Type |
|------|------|
| [awscc_networkmanager_core_network.core_network](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/networkmanager_core_network) | resource |
| [awscc_networkmanager_global_network.global_network](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/networkmanager_global_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_core_network"></a> [core\_network](#input\_core\_network) | Core Network information. | <pre>object({<br>    description     = string<br>    policy_document = any<br>  })</pre> | n/a | yes |
| <a name="input_global_network"></a> [global\_network](#input\_global\_network) | Global Network - if the ID is not provided, the module creates it. | <pre>object({<br>    id          = optional(string)<br>    description = optional(string)<br>  })</pre> | n/a | yes |
| <a name="input_create_global_network"></a> [create\_global\_network](#input\_create\_global\_network) | (optional) Whether to create the global network or not. Must pass `var.global_network.id` if `false`. Defaults to `true`. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_core_network"></a> [core\_network](#output\_core\_network) | Core Network information. |
| <a name="output_global_network"></a> [global\_network](#output\_global\_network) | Global Network information. |
<!-- END_TF_DOCS -->