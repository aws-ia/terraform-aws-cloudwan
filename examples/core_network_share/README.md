<!-- BEGIN_TF_DOCS -->
# AWS Cloud WAN Module - Sharing Core Network

This example creates an AWS Network Manager Global Network and Core Network from scratch, sharing the Core Network with the AWS Account provided in the `aws_account_share` - we recommend the use of a *terraform.tfvars* file to indicate the AWS Account in your testing environment.

**Remember that if you are using the AWS Cloud WAN to share the Core Network, you need to create the resources in us-east-1 (North Virginia)**

## Usage

- Initialize Terraform using `terraform init`.
- Now you can deploy the rest of the infrastructure using `terraform apply`.
- To delete everything, use `terraform destroy`.

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
| <a name="module_cloud_wan"></a> [cloud\_wan](#module\_cloud\_wan) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_networkmanager_core_network_policy_document.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/networkmanager_core_network_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_share"></a> [aws\_account\_share](#input\_aws\_account\_share) | AWS Account ID (to share the Core Network) | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region. | `string` | `"us-east-1"` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Example identifier. | `string` | `"core-network-share"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_core_network_id"></a> [core\_network\_id](#output\_core\_network\_id) | Core Network ID. |
| <a name="output_global_network_id"></a> [global\_network\_id](#output\_global\_network\_id) | Global Network ID. |
| <a name="output_ram_resource_share"></a> [ram\_resource\_share](#output\_ram\_resource\_share) | AWS RAM Resource Share. |
<!-- END_TF_DOCS -->