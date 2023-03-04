package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestExamplesBasePolicy(t *testing.T) {

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/base_policy",
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}