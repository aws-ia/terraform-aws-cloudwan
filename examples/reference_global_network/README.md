<!-- BEGIN_TF_DOCS -->
# AWS Cloud WAN Module - Example with a Network Manager Global Network created

This example creates a Cloud WAN Core Network from scratch. It supposes that a Network Manager Global Network is already created, so it takes the ID as parameter.

## Usage

- Initialize Terraform using `terraform init`.
- Now you can deploy the rest of the infrastructure using `terraform apply`.
- To delete everything, use `terraform destroy`.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.57.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.57.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudwan"></a> [cloudwan](#module\_cloudwan) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_networkmanager_global_network.global_network](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkmanager_global_network) | resource |
| [aws_networkmanager_core_network_policy_document.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/networkmanager_core_network_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Example identifier. | `string` | `"reference-global-network"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_core_network_id"></a> [core\_network\_id](#output\_core\_network\_id) | Core Network ID. |
| <a name="output_global_network_id"></a> [global\_network\_id](#output\_global\_network\_id) | Global Network ID. |
<!-- END_TF_DOCS -->