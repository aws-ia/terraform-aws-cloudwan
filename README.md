<!-- BEGIN_TF_DOCS -->
# AWS Cloud WAN Module

This module can be used to deploy an [AWS Cloud WAN](https://docs.aws.amazon.com/vpc/latest/cloudwan/what-is-cloudwan.html) network - with the Core Network as main resource. A Global Network (the high-level container for the Core Network), it is also created if required.

## Usage

The example below builds an AWS Network Manager Global Network and Core Network from scratch. The Core Network needs the ID of the Global Network created, and also a policy document (to define the global infrastructure). You can find more information about the policy document in the [documentation](https://docs.aws.amazon.com/network-manager/latest/cloudwan/cloudwan-policy-change-sets.html)

```hcl
module "cloudwan" {
  source  = "aws-ia/cloudwan/aws"
  version = "3.x.x"

  global_network = {
    description = "Global Network - AWS Cloud WAN Module"

    tags = {
      Name "global-network"
    }
  }
  core_network = {
    description     = "Core Network - AWS Cloud WAN Module"
    policy_document = data.aws_networkmanager_core_network_policy_document.main.json

    tags = {
      Name = "core-network"
    }
  }

  tags = {
      Module = "aws-ia/cloudwan/aws"
  }
}
```

If you already have a Network Manager Global Network created, you can pass the ID as variable and only create the Core Network.

```hcl
module "cloudwan" {
  source  = "aws-ia/cloudwan/aws"
  version = "3.x.x"

  global_network_id "global-network-021aedd98c7487b93"

  core_network = {
    description     = "Global Network - AWS CloudWAN Module"
    policy_document = data.aws_networkmanager_core_network_policy_document.main.json
    tags = {
      Name = "core-network"
    }
  }

  tags = {
      Module = "aws-ia/cloudwan/aws"
  }
}
```

In addition, when creating a new Core Network, you can also share it using [AWS Resource Access Manager](https://docs.aws.amazon.com/ram/latest/userguide/what-is.html) (RAM). You can [share a core network](https://docs.aws.amazon.com/network-manager/latest/cloudwan/cloudwan-share-network.html) across accounts or across your organization. Important to note that **you must share your global resource from the N. Virginia (us-east-1) Region so that all other Regions can see the global resource.**

```hcl
module "cloud_wan" {
  source  = "aws-ia/cloudwan/aws"
  version = "3.x.x"

  global_network = {
    description = "Global Network - ${var.identifier}"

    tags = {
      Name = "global-network"
    }
  }

  core_network = {
    description     = "Core Network - ${var.identifier}"
    policy_document = data.aws_networkmanager_core_network_policy_document.policy.json

    resource_share_name                      = "core-network-share"
    resource_share_allow_external_principals = false
    ram_share_principals                     = [org-XXX]

    tags = {
      Name = "core-network"
    }
  }

  tags = {
    Project = var.identifier
  }
}
```

## Policy Creation

Policy documents can be passed as a string of JSON or using the [policy\_document data source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/networkmanager_core_network_policy_document)

```hcl
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

## When do I need to create the *base\_policy*?

You will see two attributes when defining the `var.core_network` variable are *base\_policy\_document* and *base\_policy\_regions*, used in the module to define the *base\_policy*, *base\_policy\_document*, and *base\_policy\_regions* attributes in the `aws_networkmanager_core_network` resource. But... why do we need the *base\_policy*?

First of all, let's start explaining why we use the `aws_networkmanager_core_network_policy_attachment` resource. When adding an inspection layer to AWS Cloud WAN, a static route is needed - from any of the segments pointing to an Inspection VPC. As you need to reference the attachmend ID of the Inspection VPC(s), a circular dependency is created. To avoid this circular dependency, the `aws_networkmanager_core_network_policy_attachment` was created to decouple the creation of the Core Network to the policy document attachment, so when you deploy from scratch your architecture it proceeds as follows:

* Creation of Global Network (if not done already) and Core Network.
* Creation of Core Network attachments.
* Attachment of the policy document - generation of the network.

**Important to note** that to get this behaviour you need to use the `aws_networkmanager_core_network_policy_document` data source.

However, there's still one challenge to overcome: you cannot attach resources to the Core Network without an active policy. And it makes sense, as in the policy you indicate the AWS Regions in which you want to create CNEs (Core Network Edges). Without policy, there are no CNEs and it's impossible to attach anything. Here is where *base\_policy* is going to help us: a temporal policy document is generated so the attachments can be created before applying the policy document where you reference some of those attachment IDs.

You have two ways to define the *base\_policy*:

* Use the *base\_policy\_document* argument if you are providing specific configuration on the CNE ASNs in the final policy document you want to deploy.
* Use the *base\_policy\_regions* argument to simply indicate the AWS Regions where you want to create attachments prior to the deployment of the final policy document.

**What happens when adding new attachments to a current Core Network with a live policy?** If any of these attachmens are referenced in the policy document, those are going to be created first and then the policy is going to be updated. The *base\_policy* attribute won't do anything, as there's a current live policy - we don't need this temporal policy.

**What happens when adding new AWS Regions to a current Core Network with a live policy?** The *base\_policy* won't help us here, as creating a temporal policy with the new AWS Region will create a network disruption - as we already have a network configuration applied. That's why, when adding new AWS Regions, we need a two-step deployment:

* Step 1: Update and apply the policy document with the new AWS Region(s).
* Step 2: Create the new attachment(s) and update the policy document if any static route is needed.

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
| <a name="module_core_network_tags"></a> [core\_network\_tags](#module\_core\_network\_tags) | aws-ia/label/aws | 0.0.5 |
| <a name="module_global_network_tags"></a> [global\_network\_tags](#module\_global\_network\_tags) | aws-ia/label/aws | 0.0.5 |
| <a name="module_tags"></a> [tags](#module\_tags) | aws-ia/label/aws | 0.0.5 |

## Resources

| Name | Type |
|------|------|
| [aws_networkmanager_core_network.core_network](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkmanager_core_network) | resource |
| [aws_networkmanager_core_network_policy_attachment.policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkmanager_core_network_policy_attachment) | resource |
| [aws_networkmanager_global_network.global_network](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkmanager_global_network) | resource |
| [aws_ram_principal_association.principal_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_resource_association.resource_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_share.resource_share](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_core_network"></a> [core\_network](#input\_core\_network) | Core Network definition - providing information to this variable will create a new Core Network. Conflicts with `var.core_network_arn`.<br>This variable expects the following attributes:<br>- `description`                              = (Optional\|string) Core Network's description.<br>- `policy_document`                          = (Optional\|any) Core Network's policy in JSON format. It is recommended the use of the [Core Network Document data source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/networkmanager_core_network_policy_document)<br>- `base_policy_document`                     = (Optional\|any) Conflicts with `base_policy_regions`. Sets the base policy document for the Core Network. For more information about the need of the base policy, check the README document.<br>- `base_policy_regions`                      = (Optional\|list(string)) Conflicts with `base_policy_document`. List of AWS Regions to create the base policy document in the Core Network. For more information about the need of the base policy, check the README document.<br>- `resource_share_name`                      = (Optional\|string) AWS Resource Access Manager (RAM) Resource Share name. Providing this value, RAM resources will be created to share the Core Network with the principals indicated in `var.core_network.ram_share_principals`.<br>- `resource_share_allow_external_principals` = (Optional\|bool) Indicates whether principals outside your AWS Organization can be associated with a Resource Share.<br>- `ram_share_principals`                     = (Optional\|list(string)) List of principals (AWS Account or AWS Organization) to share the Core Network with.<br>- `tags`                                     = (Optional\|map(string)) Tags to apply to the Core Network and RAM Resource Share (if created). | `any` | `{}` | no |
| <a name="input_core_network_arn"></a> [core\_network\_arn](#input\_core\_network\_arn) | (Optional) Core Network ARN. Conflicts with `var.core_network`. | `string` | `null` | no |
| <a name="input_global_network"></a> [global\_network](#input\_global\_network) | Global Network definition - providing information to this variable will create a new Global Network. Conflicts with `var.global_network_id`.<br>This variable expects the following attributes:<br>- `description` = (Optional\|string) Global Network's description.<br>- `tags`        = (Optional\|map(string)) Tags to apply to the Global Network.<pre></pre> | `any` | `{}` | no |
| <a name="input_global_network_id"></a> [global\_network\_id](#input\_global\_network\_id) | (Optional) Global Network ID. Conflicts with `var.global_network`. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_core_network"></a> [core\_network](#output\_core\_network) | Core Network. Full output of aws\_networkmanager\_core\_network. |
| <a name="output_global_network"></a> [global\_network](#output\_global\_network) | Global Network. Full output of aws\_networkmanager\_global\_network. |
| <a name="output_ram_resource_share"></a> [ram\_resource\_share](#output\_ram\_resource\_share) | Resource Access Manager (RAM) Resource Share. Full output of aws\_ram\_resource\_share. |
<!-- END_TF_DOCS -->