terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # Floor: retention_policy_in_days only exists from 4.0.0 onwards. The final
      # 3.x release (3.117.1) still uses the removed retention_policy block.
      # trust_policy_enabled is not used: azurerm 5.0 removed it.
      # Ceiling: tested against 5.x; 6.0 has not been vetted.
      version = ">= 4.0, < 6.0"
    }
  }
}
