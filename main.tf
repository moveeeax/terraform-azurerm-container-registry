resource "azurerm_container_registry" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  public_network_access_enabled = var.public_network_access_enabled
  anonymous_pull_enabled        = var.anonymous_pull_enabled
  export_policy_enabled         = var.export_policy_enabled
  quarantine_policy_enabled     = var.quarantine_policy_enabled
  trust_policy_enabled          = var.trust_policy_enabled
  retention_policy_in_days      = var.retention_policy_in_days

  tags = var.tags

  # Azure gates several of these settings on the registry SKU and rejects them
  # at apply time with an opaque API error. The preconditions below surface the
  # same constraints during `terraform plan` instead.
  lifecycle {
    precondition {
      condition     = var.public_network_access_enabled || var.sku == "Premium"
      error_message = "public_network_access_enabled = false requires sku = \"Premium\"; network rules and private endpoints are a Premium-only ACR feature."
    }

    precondition {
      condition     = !var.anonymous_pull_enabled || contains(["Standard", "Premium"], var.sku)
      error_message = "anonymous_pull_enabled = true requires sku = \"Standard\" or \"Premium\"; anonymous pull is not available on Basic."
    }

    precondition {
      condition     = var.export_policy_enabled || var.sku == "Premium"
      error_message = "export_policy_enabled = false requires sku = \"Premium\"; the export policy is a Premium-only ACR feature."
    }

    precondition {
      condition     = var.export_policy_enabled || !var.public_network_access_enabled
      error_message = "export_policy_enabled = false requires public_network_access_enabled = false; Azure rejects a disabled export policy on a publicly reachable registry."
    }

    precondition {
      condition     = !var.quarantine_policy_enabled || var.sku == "Premium"
      error_message = "quarantine_policy_enabled = true requires sku = \"Premium\"."
    }

    precondition {
      condition     = !var.trust_policy_enabled || var.sku == "Premium"
      error_message = "trust_policy_enabled = true requires sku = \"Premium\"."
    }

    precondition {
      condition     = var.retention_policy_in_days == null || var.sku == "Premium"
      error_message = "retention_policy_in_days requires sku = \"Premium\"."
    }
  }
}
