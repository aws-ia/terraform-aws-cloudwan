# Changes from 1.x to 2.x

Changes from version 1 to version 2 of this module are minimal, and **don't entail any downtime**. However, check this guide to understand the new behavior.

There's a new resource added -  `aws_networkmanager_core_network_policy_attachment`- that doesn't create new resources, rather it decouples the creation of the Core Network to the policy document attachment. This is used to avoid circular dependencies when you reference Core Network attachment IDs in the policy document.

So, if you move from version 1.x.x to 2.x.x and you do a `terraform plan`, you will see 1 new resource to be created. When doing a `terraform apply`, it will generate a new policy version in the Core Network containing the same policy you currently have (unless you apply changes). You won't have any disruption.

If you want to avoid the creation of this resource and the generation of the new policy version, you can import the resource by doing:

```
terraform import module.cloudwan.aws_networkmanager_core_network_policy_attachment.policy_attachment core-network-XXX
```

If you do a `terraform plan`, you won't see any changes in the infrastructure.