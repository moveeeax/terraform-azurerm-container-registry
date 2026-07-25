terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0, < 4.0"
    }
  }
}

# The azurerm 4.x provider needs a subscription. Export ARM_SUBSCRIPTION_ID (or
# set subscription_id here) before running plan/apply, otherwise the provider
# fails to configure.
provider "azurerm" {
  features {}
}

resource "random_string" "suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "azurerm_resource_group" "example" {
  name     = "example-acr-hardened-rg"
  location = "eastus"
}

# A Premium registry with the network and policy controls turned on. Every
# setting below is Premium-gated; the module refuses them at plan time on a
# Basic or Standard registry rather than failing halfway through an apply.
module "container_registry" {
  source = "../.."

  name                = "hardenedacr${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Premium"

  admin_enabled                 = false
  anonymous_pull_enabled        = false
  public_network_access_enabled = false
  export_policy_enabled         = false
  quarantine_policy_enabled     = true
  trust_policy_enabled          = true
  retention_policy_in_days      = 30

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

output "acr_id" {
  value = module.container_registry.id
}
