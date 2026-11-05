terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 6.0"
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

# ACR names are globally unique and allow alphanumerics only, so the example
# generates its own suffix rather than shipping a name that is already taken.
resource "random_string" "suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "azurerm_resource_group" "example" {
  name     = "example-acr-rg"
  location = "eastus"
}

module "container_registry" {
  source = "../.."

  name                = "exampleacr${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard"

  # Defaults already keep the shared admin credential and anonymous pull off;
  # they are restated here so the example documents the intended posture.
  admin_enabled          = false
  anonymous_pull_enabled = false

  tags = {
    Environment = "sandbox"
    ManagedBy   = "terraform"
  }
}

output "acr_login_server" {
  value = module.container_registry.login_server
}
