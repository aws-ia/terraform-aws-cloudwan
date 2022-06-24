package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestExamplesWithGlobalNetwork(t *testing.T) {

	globalNetworkBase := &terraform.Options{
		TerraformDir: "./hcl_fixtures/global_network_base",
	}
	defer terraform.Destroy(t, globalNetworkBase)
	terraform.InitAndApply(t, globalNetworkBase)

	gNId := terraform.Output(t, globalNetworkBase, "global_network_id")

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/with_globalnetwork",
		Vars: map[string]interface{}{
			"global_network_id": gNId,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}
