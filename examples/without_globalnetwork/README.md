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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.21.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudwan"></a> [cloudwan](#module\_cloudwan) | ../.. | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwan_resources"></a> [cloudwan\_resources](#output\_cloudwan\_resources) | CloudWAN resources created. |
<!-- END_TF_DOCS -->