<!-- BEGIN_TF_DOCS -->
# AWS Cloud WAN Module - Example without a Network Manager Global Network created

This example creates a Network Manager Global Network and Cloud WAN Core Network from scratch, using the Terraform AWS Cloud Control Provider.

## Usage

- Initialize Terraform using `terraform init`.
- Now you can deploy the rest of the infrastructure using `terraform apply`.
- To delete everything, use `terraform destroy`.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.25.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudwan"></a> [cloudwan](#module\_cloudwan) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_networkmanager_core_network_policy_document.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/networkmanager_core_network_policy_document) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwan_resources"></a> [cloudwan\_resources](#output\_cloudwan\_resources) | CloudWAN resources created. |
<!-- END_TF_DOCS -->