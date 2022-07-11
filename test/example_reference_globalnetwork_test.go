package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestExamplesWithGlobalNetwork(t *testing.T) {

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/reference_global_network",
		Vars:         map[string]interface{}{},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}
