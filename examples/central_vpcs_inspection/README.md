<!-- BEGIN_TF_DOCS -->
# AWS Cloud WAN Module - Central VPCs (with Inspection) example

This example creates a Network Manager Global Network and Cloud WAN Core Network, with central VPCs (types *inspection*, *egress\_with\_inspection*, and *ingress\_with\_inspection*). AWS Network Firewall resource (and VPC routing) is created in each central VPC.

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
| <a name="provider_http"></a> [http](#provider\_http) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_wan"></a> [cloud\_wan](#module\_cloud\_wan) | ../.. | n/a |
| <a name="module_cloudwan_central_vpcs"></a> [cloudwan\_central\_vpcs](#module\_cloudwan\_central\_vpcs) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_networkfirewall_firewall_policy.egress_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy) | resource |
| [aws_networkfirewall_firewall_policy.ingress_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy) | resource |
| [aws_networkfirewall_firewall_policy.inspection_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy) | resource |
| [aws_networkfirewall_rule_group.allow_domains](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.allow_east_west_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.allow_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.drop_remote](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkmanager_core_network_policy_document.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/networkmanager_core_network_policy_document) | data source |
| [http_http.myip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region. | `string` | `"eu-west-1"` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Example identifier. | `string` | `"central-vpcs-inspection"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_network_firewall"></a> [aws\_network\_firewall](#output\_aws\_network\_firewall) | AWS Network Firewall IDs. |
| <a name="output_central_vpcs"></a> [central\_vpcs](#output\_central\_vpcs) | Central VPC IDs. |
| <a name="output_cloud_wan"></a> [cloud\_wan](#output\_cloud\_wan) | AWS Cloud WAN resources. |
<!-- END_TF_DOCS -->