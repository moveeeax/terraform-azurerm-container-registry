terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # Floor: trust_policy_enabled and retention_policy_in_days only exist from
      # 4.0.0 onwards. The final 3.x release (3.117.1) still uses the removed
      # trust_policy / retention_policy blocks and rejects both arguments.
      # Ceiling: 5.0 has not shipped, so its schema cannot be relied on.
      version = ">= 4.0, < 5.0"
    }
  }
}
