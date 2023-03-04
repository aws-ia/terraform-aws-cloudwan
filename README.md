<!-- BEGIN_TF_DOCS -->
# AWS Cloud WAN Module

This module can be used to deploy an [AWS Cloud WAN](https://docs.aws.amazon.com/vpc/latest/cloudwan/what-is-cloudwan.html) Core Network using the [Terraform AWS Cloud Control Provider](https://github.com/hashicorp/terraform-provider-awscc). A Core Network is built inside a Global Network, so if that resources is not provided, it is also created. [Here is a guide](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/using-aws-with-awscc-provider) for using the resources together to create a core network.

## Usage

The example below builds a Network Manager Global Network and a Cloud WAN Core Network from scratch. The Core Network needs the ID of the Global Network created, and also a policy document (to define the global infrastructure). An example of a policy document can be found [here](https://github.com/aws-ia/terraform-aws-cloudwan/blob/61f2261fc753dca2317b7c8b3973180894d8876e/examples/basic/policy.tf).

```hcl
module "cloudwan" {
  source  = "aws-ia/cloudwan/aws"
  version = "2.x.x"

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
  source  = "aws-ia/cloudwan/aws"
  version = "2.x.x"

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

## When do I need to create the *base\_policy*?

You will see that one of the attributes of the Core Network is *base\_policy\_regions*, that it is used in the module to define the *base\_policy* and *base\_policy\_regions* attributes in the `aws_networkmanager_core_network` resource. But... why do we need the *base\_policy*?

First of all, let's start explaining why we use the `aws_networkmanager_core_network_policy_attachment` resource. When adding an inspection layer to AWS Cloud WAN, a static route is needed - from any of the segments pointing to an Inspection VPC. As you need to reference the attachmend ID of the Inspection VPC(s), a circular dependency is created. To avoid this circular dependency, the `aws_networkmanager_core_network_policy_attachment` was created to decouple the creation of the Core Network to the policy document attachment, so when you deploy from scratch your architecture it proceeds as follows:

* Creation of Global Network (if not done already) and Core Network.
* Creation of Core Network attachments.
* Attachment of the policy document - generation of the network.

**Important to note** that to get this behaviour you need to use the `aws_networkmanager_core_network_policy_document` data source.

However, there's still one challenge to overcome: you cannot attach resources to the Core Network without an active policy. And it makes sense, as in the policy you indicate the AWS Regions in which you want to create CNEs (Core Network Edges). Without policy, there are no CNEs and it's impossible to attach anything. Here is where *base\_policy* is going to help us: a temporal policy document is generated (in the AWS Regions you indicate in *base\_policy\_regions*) so the attachments can be created before applying the policy document where you reference some of those attachment IDs.

**What happens when adding new attachments to a current Core Network with a live policy?** If any of these attachmens are referenced in the policy document, those are going to be created first and then the policy is going to be updated. The *base\_policy* attribute won't do anything, as there's a current live policy - we don't need this temporal policy.

**What happens when adding new AWS Regions to a current Core Network with a live policy?** The *base\_policy* won't help us here, as creating a temporal policy with the new AWS Region will create a network disruption - as we already have a network configuration applied. That's why, when adding new AWS Regions, we need a two-step deployment:

* Step 1: Update and apply the policy document with the new AWS Region(s).
* Step 2: Create the new attachment(s) and update the policy document if any static route is needed.

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
| <a name="module_tags"></a> [tags](#module\_tags) | aws-ia/label/aws | 0.0.5 |

## Resources

| Name | Type |
|------|------|
| [aws_networkmanager_core_network.core_network](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkmanager_core_network) | resource |
| [aws_networkmanager_core_network_policy_attachment.policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkmanager_core_network_policy_attachment) | resource |
| [aws_networkmanager_global_network.global_network](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkmanager_global_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_core_network"></a> [core\_network](#input\_core\_network) | Core Network definition. The following attributes are required:<br>- `description`     = (string) Core Network's description.<br>- `policy_document` = (any) Core Network's policy in JSON format. It is recommended the use of the [Core Network Document data source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/networkmanager_core_network_policy_document)<br>- `base_policy_regions` = (optional\|list(string)) List of AWS Regions to create the base policy in the Core Network. For more information about the need of the base policy, check the README document.<pre></pre> | <pre>object({<br>    description         = string<br>    policy_document     = any<br>    base_policy_regions = optional(list(string))<br>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map(string)` | n/a | yes |
| <a name="input_global_network"></a> [global\_network](#input\_global\_network) | Global Network definition. This variable expects the following attributes:<br>- `create = (Required|string) Indicating if a Global Network should be created or not. Default to `true`.<br>- `id` = (Optional|string) ID of a current Global Network created outside the module. Attribute required when `var.create\_global\_network` is **false**.<br>- `description` = (Optional|string) Description of the new Global Network to create. Attribute required when `var.create\_global\_network` is **true**.<br>`<pre></pre> | <pre>object({<br>    create      = bool<br>    id          = optional(string)<br>    description = optional(string)<br>  })</pre> | <pre>{<br>  "create": true<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_core_network"></a> [core\_network](#output\_core\_network) | Core Network. Full output of aws\_networkmanager\_core\_network. |
| <a name="output_global_network"></a> [global\_network](#output\_global\_network) | Global Network. Full output of aws\_networkmanager\_global\_network. |
<!-- END_TF_DOCS -->