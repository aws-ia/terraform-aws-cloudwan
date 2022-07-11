<!-- BEGIN_TF_DOCS -->
# AWS Cloud WAN Module - Example with a Network Manager Global Network created

This example creates a Cloud WAN Core Network from scratch, using the Terraform AWS Cloud Control Provider. It supposes that a Network Manager Global Network is already created (using the Terraform AWS Provider), so it takes the ID as parameter.

## Usage

- Initialize Terraform using `terraform init`.
- As the Global Network should be created beforehand, first you need to deploy that resource first: `terraform apply -target=aws_networkmanager_global_network.global_network`
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
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | >= 0.25.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudwan"></a> [cloudwan](#module\_cloudwan) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [awscc_networkmanager_global_network.test](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/networkmanager_global_network) | resource |
| [aws_networkmanager_core_network_policy_document.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/networkmanager_core_network_policy_document) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_core_network"></a> [core\_network](#output\_core\_network) | Core Network - created with AWS CloudWAN module. |
<!-- END_TF_DOCS -->