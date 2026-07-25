# Proves the example actually reaches a complete plan, not just `terraform
# validate`. Run with `terraform test` from this directory; needs Terraform >= 1.7
# for mock_provider but no Azure credentials.

mock_provider "azurerm" {}
mock_provider "random" {}

run "example_plans" {
  command = plan
}
