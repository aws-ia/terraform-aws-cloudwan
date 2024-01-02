<!-- BEGIN_TF_DOCS -->
# AWS Cloud WAN Module - Central VPCs example

This example creates a Network Manager Global Network and Cloud WAN Core Network, with central VPCs (1 per each type).

## Usage

- Initialize Terraform using `terraform init`.
- First create the Global Network and Core Network using `terraform apply -target="module.cloud_wan"`.
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
| <a name="module_cloudwan_central_vpcs"></a> [cloudwan\_central\_vpcs](#module\_cloudwan\_central\_vpcs) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_networkmanager_core_network_policy_document.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/networkmanager_core_network_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region. | `string` | `"eu-west-1"` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Example identifier. | `string` | `"create-global-core-network"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_central_vpcs"></a> [central\_vpcs](#output\_central\_vpcs) | Central VPC IDs. |
| <a name="output_cloud_wan"></a> [cloud\_wan](#output\_cloud\_wan) | AWS Cloud WAN resources. |
<!-- END_TF_DOCS -->