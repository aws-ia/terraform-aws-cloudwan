# Changes from 2.x to 3.x

We are moving to version 3 of the module due we have introduced changes in the variables' definition - to simplify the module's functionality as we add new capabilities. With this change, now the creation of the Core Network is optional, which means in the Terraform state the Core Network will move from `` to ``. However, moving from version 2 to version 3 **won't entail any downtime** - as Terraform will automatically catch this change and update the Terraform state appropriately.

```
# module.cloud_wan.aws_networkmanager_core_network_policy_attachment.policy_attachment has moved to module.cloud_wan.aws_networkmanager_core_network_policy_attachment.policy_attachment[0]
```

This guide will explain how the module definition changes from version 2 to 3.

## Example 1: Creating both Global Network and Core Network using the module

* Version 2.x.x

```hcl
module "cloud_wan" {
  source  = "aws-ia/cloudwan/aws"
  version = "2.0.0"

  global_network = {
    create      = true
    description = "Global Network - ${var.identifier}"
  }

  core_network = {
    description     = "Core Network - ${var.identifier}"
    policy_document = data.aws_networkmanager_core_network_policy_document.policy.json
  }

  tags = {
    Name = var.identifier
  }
}
```

* Version 3.x.x

```hcl
module "cloud_wan" {
  source  = "aws-ia/cloudwan/aws"
  version = "3.0.0"

  global_network = {
    description = "Global Network - ${var.identifier}"
  }

  core_network = {
    description     = "Core Network - ${var.identifier}"
    policy_document = data.aws_networkmanager_core_network_policy_document.policy.json
  }

  tags = {
    Name = var.identifier
  }
}
```

## Example 2: Creating Core Network using the module referencing an existing Global Network

* Version 2.x.x

```hcl
module "cloudwan" {
  source  = "aws-ia/cloudwan/aws"
  version = "2.0.0"

  global_network = {
    create = false
    id     = aws_networkmanager_global_network.global_network.id
  }

  core_network = {
    description     = "Global Network - AWS CloudWAN Module"
    policy_document = data.aws_networkmanager_core_network_policy_document.policy.json
  }

  tags = {
    Name = var.identifier
  }
}
```

* Version 3.x.x

```hcl
module "cloudwan" {
  source  = "aws-ia/cloudwan/aws"
  version = "3.0.0"

  global_network_id = aws_networkmanager_global_network.global_network.id

  core_network = {
    description     = "Global Network - AWS CloudWAN Module"
    policy_document = data.aws_networkmanager_core_network_policy_document.policy.json
  }

  tags = {
    Name = var.identifier
  }
}
```