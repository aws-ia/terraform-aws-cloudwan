package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestExamplesWithoutGlobalNetwork(t *testing.T) {

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/basic",
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}
