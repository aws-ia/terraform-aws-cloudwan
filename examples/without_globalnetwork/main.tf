# Calling the CloudWAN Module
module "cloudwan" {
  source = "../.."

  global_network = {
    description = "Global Network - AWS CloudWAN Module"
  }
  core_network = {
    description     = "Core Network - AWS CloudWAN Module"
    policy_document = local.policy
  }

  tags = {
    Name = "cloudwan-module-without"
  }
}
