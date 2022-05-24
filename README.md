<!-- BEGIN_TF_DOCS -->
# AWS Cloud WAN Module

This module can be used to deploy an [AWS Cloud WAN](https://docs.aws.amazon.com/vpc/latest/cloudwan/what-is-cloudwan.html) Core Network using the [Terraform AWS Cloud Control Provider](https://github.com/hashicorp/terraform-provider-awscc). A Core Network is built inside a Global Network, so if that resources is not provided, it is also created.

## Usage

The example below builds a Network Manager Global Network and a Cloud WAN Core Network from scratch. The Core Network needs the ID of the Global Network created, and also a policy document (to define the global infrastructure). An example of a policy document can be found [here](./examples/without\_globalnetwork/locals.tf).

```hcl
module "cloudwan" {
  source = "../.."

  global_network = {
    description = "Global Network - AWS CloudWAN Module"
  }
  core_network = {
    description            = "Core Network - AWS CloudWAN Module"
    policy_document        = local.policy
  }

  tags = {
      Name = "cloudwan-module-without"
  }
}
```

If you already have a Network Manager Global Network created, you can pass the ID as variable and only create the Cloud Wan Core Network.

```hcl
module "cloudwan" {
  source = "../.."

  global_network = {
    id = aws_networkmanager_global_network.global_network.id
  }
  core_network = {
    description            = "Global Network - AWS CloudWAN Module"
    policy_document        = local.policy
  }

  tags = {
      Name = "cloudwan-module-with"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.3 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.21.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | 0.21.0 |

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
| <a name="input_core_network"></a> [core\_network](#input\_core\_network) | Core Network information. | <pre>object({<br>        description = string<br>        policy_document = any<br>    })</pre> | n/a | yes |
| <a name="input_global_network"></a> [global\_network](#input\_global\_network) | Global Network - if the ID is not provided, the module creates it. | <pre>object({<br>        id = optional(string)<br>        description = optional(string)<br>    })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_core_network"></a> [core\_network](#output\_core\_network) | Core Network information. |
| <a name="output_global_network"></a> [global\_network](#output\_global\_network) | Global Network information. |
<!-- END_TF_DOCS -->