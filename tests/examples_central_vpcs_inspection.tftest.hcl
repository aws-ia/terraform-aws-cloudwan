run "core_network" {
  command = apply

  plan_options {
    target = [module.cloud_wan]
  }

  module {
    source = "./examples/central_vpcs_inspection"
  }
}

run "validate" {
  command = apply
  module {
    source = "./examples/central_vpcs_inspection"
  }
}