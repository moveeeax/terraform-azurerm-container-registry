# Run with `terraform test`. mock_provider needs Terraform >= 1.7; the module
# itself still supports >= 1.5, so this requirement is test-only and must not be
# copied into versions.tf.

mock_provider "azurerm" {}

variables {
  name                = "unittestacr"
  resource_group_name = "unit-test-rg"
  location            = "eastus"
}

run "defaults_are_safe" {
  command = plan

  assert {
    condition     = azurerm_container_registry.this.admin_enabled == false
    error_message = "The shared static admin credential must be disabled by default."
  }

  assert {
    condition     = azurerm_container_registry.this.anonymous_pull_enabled == false
    error_message = "Anonymous (unauthenticated) pull must be disabled by default."
  }

  assert {
    condition     = azurerm_container_registry.this.quarantine_policy_enabled == false
    error_message = "quarantine_policy_enabled must default to false so the default Standard SKU stays valid."
  }

  assert {
    condition     = azurerm_container_registry.this.trust_policy_enabled == false
    error_message = "trust_policy_enabled must default to false so the default Standard SKU stays valid."
  }

  assert {
    condition     = azurerm_container_registry.this.retention_policy_in_days == null
    error_message = "retention_policy_in_days must default to null so the default Standard SKU stays valid."
  }

  assert {
    condition     = azurerm_container_registry.this.sku == "Standard"
    error_message = "sku must default to Standard."
  }
}

run "rejects_invalid_sku" {
  command = plan

  variables {
    sku = "Ultra"
  }

  expect_failures = [var.sku]
}

run "rejects_invalid_registry_name" {
  command = plan

  variables {
    name = "not-a-valid-acr-name"
  }

  expect_failures = [var.name]
}

run "rejects_out_of_range_retention" {
  command = plan

  variables {
    sku                      = "Premium"
    retention_policy_in_days = 400
  }

  expect_failures = [var.retention_policy_in_days]
}

run "private_registry_requires_premium" {
  command = plan

  variables {
    sku                           = "Standard"
    public_network_access_enabled = false
  }

  expect_failures = [azurerm_container_registry.this]
}

run "anonymous_pull_rejected_on_basic" {
  command = plan

  variables {
    sku                    = "Basic"
    anonymous_pull_enabled = true
  }

  expect_failures = [azurerm_container_registry.this]
}

run "quarantine_policy_requires_premium" {
  command = plan

  variables {
    sku                       = "Standard"
    quarantine_policy_enabled = true
  }

  expect_failures = [azurerm_container_registry.this]
}

run "trust_policy_requires_premium" {
  command = plan

  variables {
    sku                  = "Standard"
    trust_policy_enabled = true
  }

  expect_failures = [azurerm_container_registry.this]
}

run "retention_policy_requires_premium" {
  command = plan

  variables {
    sku                      = "Standard"
    retention_policy_in_days = 30
  }

  expect_failures = [azurerm_container_registry.this]
}

run "disabled_export_policy_requires_private_registry" {
  command = plan

  variables {
    sku                           = "Premium"
    public_network_access_enabled = true
    export_policy_enabled         = false
  }

  expect_failures = [azurerm_container_registry.this]
}

run "hardened_premium_configuration_is_accepted" {
  command = plan

  variables {
    sku                           = "Premium"
    admin_enabled                 = false
    anonymous_pull_enabled        = false
    public_network_access_enabled = false
    export_policy_enabled         = false
    quarantine_policy_enabled     = true
    trust_policy_enabled          = true
    retention_policy_in_days      = 30
  }

  assert {
    condition     = azurerm_container_registry.this.public_network_access_enabled == false
    error_message = "The hardened configuration should keep the registry off the public internet."
  }

  assert {
    condition     = azurerm_container_registry.this.retention_policy_in_days == 30
    error_message = "retention_policy_in_days should be passed through to the registry."
  }
}
