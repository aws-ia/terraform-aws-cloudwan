# Changes from 0.x to 1.x

If you are using a version 0.x of this module and want to move to a version 1.x, you will find that we have migrated from using the [AWSCC](https://registry.terraform.io/providers/hashicorp/awscc/latest) provider to [AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) provider for the Global and Core Network resources. If you want to udpate the version without re-creating the resources, you need to proceed as follows:

* First, add in your main.tf (or similar file) a new module definition. In this new definition you need to pass the current Global Network without creating a new one.

```hcl
module "cloudwan" {
  source  = "aws-ia/cloudwan/aws"
  version = "0.x.x"

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

module "new_cloudwan" {
  source  = "aws-ia/cloudwan/aws"
  version = "1.x.x"

  global_network = {
    create = false
    id     = "global-network-XXX"
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

* Next, do a Terraform import for the new Global and Core Network resources.

```
terraform import module.new_cloudwan.aws_networkmanager_global_network.global_network[0] global-network-XXX
terraform import module.new_cloudwan.aws_networkmanager_core_network.core_network core-network-XXX
```

* Now you can remove from the Terraform state the old resources

```
terraform state rm module.cloudwan.awscc_networkmanager_global_network.global_network[0]
terraform state rm module.new_cloudwan.awscc_networkmanager_core_network.core_network
```

* Finally, you can remove the definition of the old module (the one using version 0.x) from your main.tf file (or similar)