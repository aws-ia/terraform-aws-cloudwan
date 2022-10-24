<!-- BEGIN_TF_DOCS -->
# AWS Cloud WAN Module

This module can be used to deploy an [AWS Cloud WAN](https://docs.aws.amazon.com/vpc/latest/cloudwan/what-is-cloudwan.html) Core Network using the [Terraform AWS Cloud Control Provider](https://github.com/hashicorp/terraform-provider-awscc). A Core Network is built inside a Global Network, so if that resources is not provided, it is also created. [Here is a guide](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/using-aws-with-awscc-provider) for using the resources together to create a core network.

## Usage

The example below builds a Network Manager Global Network and a Cloud WAN Core Network from scratch. The Core Network needs the ID of the Global Network created, and also a policy document (to define the global infrastructure). An example of a policy document can be found [here](https://github.com/aws-ia/terraform-aws-cloudwan/blob/61f2261fc753dca2317b7c8b3973180894d8876e/examples/basic/policy.tf).

```hcl
module "cloudwan" {
  source = "aws-ia/cloudwan"

  global_network = {
    create      = true
    description = "Global Network - AWS CloudWAN Module"
  }
  core_network = {
    description     = "Core Network - AWS CloudWAN Module"
    policy_document = data.aws_networkmanager_core_network_policy_document.main.json
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
    create = false
    id     = "global-network-021aedd98c7487b93"
  }
  core_network = {
    description     = "Global Network - AWS CloudWAN Module"
    policy_document = data.aws_networkmanager_core_network_policy_document.main.json
  }

  tags = {
      Name = "reference-preexisting-global-network"
  }
}
```

## Policy Creation

Policy documents can be passed as a string of JSON or using the [policy\_document data source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/networkmanager_core_network_policy_document)

```terraform
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

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.25.0, <= 0.33.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | >= 0.25.0, <= 0.33.0 |

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
| <a name="input_core_network"></a> [core\_network](#input\_core\_network) | Core Network definition. The following attributes are required:<br>- `description` = (string) Core Network's description.<br>- `description` = (any) Core Network's policy in JSON format. It is recommended the use of the [Core Network Document data source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/networkmanager_core_network_policy_document)<pre></pre> | <pre>object({<br>    description     = string<br>    policy_document = any<br>  })</pre> | n/a | yes |
| <a name="input_global_network"></a> [global\_network](#input\_global\_network) | Global Network definition. This variable expects the following attributes:<br>- `create = (Required|string) Indicating if a Global Network should be created or not. Default to `true`.<br>- `id` = (Optional|string) ID of a current Global Network created outside the module. Attribute required when `var.create\_global\_network` is **false**.<br>- `description` = (Optional|string) Description of the new Global Network to create. Attribute required when `var.create\_global\_network` is **true**.<br>`<pre></pre> | <pre>object({<br>    create      = bool<br>    id          = optional(string)<br>    description = optional(string)<br>  })</pre> | <pre>{<br>  "create": true<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_core_network"></a> [core\_network](#output\_core\_network) | Core Network. Full output of awscc\_networkmanager\_core\_network. |
| <a name="output_global_network"></a> [global\_network](#output\_global\_network) | Global Network. Full output of awscc\_networkmanager\_global\_network. |
<!-- END_TF_DOCS -->