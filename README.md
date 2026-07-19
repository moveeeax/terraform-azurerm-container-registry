# terraform-azurerm-container-registry

Terraform module that manages an [Azure](https://azure.microsoft.com/) Container
Registry (ACR). It creates a single registry, keeps the static admin user
disabled by default in favour of Azure AD authentication, and exposes the login
server and admin credentials for CI pipelines.

## Usage

```hcl
module "container_registry" {
  source = "github.com/moveeeax/terraform-azurerm-container-registry"

  name                = "prodacr01"
  resource_group_name = "prod-rg"
  location            = "eastus"
  sku                 = "Premium"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

A runnable example lives in [`examples/basic`](examples/basic).

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5   |
| azurerm   | >= 3.0   |

## Inputs

| Name                            | Description                                                             | Type          | Default      | Required |
|---------------------------------|-------------------------------------------------------------------------|---------------|--------------|:--------:|
| `name`                          | Name of the container registry. Globally unique, 5-50 alphanumeric.    | `string`      | n/a          |   yes    |
| `resource_group_name`           | Name of the resource group in which to create the container registry.   | `string`      | n/a          |   yes    |
| `location`                      | Azure region in which to create the container registry.                 | `string`      | n/a          |   yes    |
| `sku`                           | SKU of the container registry. One of Basic, Standard or Premium.       | `string`      | `"Standard"` |    no    |
| `admin_enabled`                 | Whether the admin user with a static username and password is enabled.  | `bool`        | `false`      |    no    |
| `public_network_access_enabled` | Whether the container registry is reachable over the public internet.   | `bool`        | `true`       |    no    |
| `tags`                          | Map of tags applied to the container registry.                          | `map(string)` | `{}`         |    no    |

## Outputs

| Name             | Description                                          |
|------------------|------------------------------------------------------|
| `id`             | ID of the container registry.                        |
| `name`           | Name of the container registry.                      |
| `login_server`   | URL used to log in with docker login.                |
| `admin_username` | Admin username, populated only when admin is enabled.|
| `admin_password` | Admin password (sensitive).                          |

## License

[MIT](LICENSE)
