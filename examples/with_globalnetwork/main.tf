# Calling the CloudWAN Module
module "cloudwan" {
  source = "../.."

  global_network = {
    id = aws_networkmanager_global_network.global_network.id
  }
  core_network = {
    description            = "Global Network - AWS CloudWAN Module"
    policy_document = local.policy
  }

  tags = {
      Name = "cloudwan-module-with"
  }
}

# Creating a Global Network using the AWS Provider
resource "aws_networkmanager_global_network" "global_network" {
  description = "Global Network - CloudWAN"

  tags = {
    Name = "Global Network CloudWAN"
    Terraform = "Managed"
    Provider = "aws"
  }
}