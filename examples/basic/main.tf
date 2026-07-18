terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "container_registry" {
  source = "../.."

  name                = "exampleacr01"
  resource_group_name = "example-rg"
  location            = "eastus"
  sku                 = "Standard"

  tags = {
    Environment = "sandbox"
    ManagedBy   = "terraform"
  }
}

output "acr_login_server" {
  value = module.container_registry.login_server
}
