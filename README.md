# terraform-azurerm-container-registry

Terraform module that manages an [Azure](https://azure.microsoft.com/) Container
Registry (ACR). It creates a single registry, keeps the static admin user
disabled by default in favour of Entra ID (Azure AD) authentication, and exposes
the login server and admin credentials for CI pipelines.

Several ACR settings are only accepted on certain SKUs and Azure rejects them
mid-apply with an opaque API error. This module checks them with resource
preconditions, so an invalid combination fails during `terraform plan` instead
of leaving a half-created registry behind.

## Usage

```hcl
module "container_registry" {
  source = "github.com/moveeeax/terraform-azurerm-container-registry"

  name                = "prodacr01"
  resource_group_name = "prod-rg"
  location            = "eastus"
  sku                 = "Premium"

  # Defaults, restated to make the posture explicit.
  admin_enabled          = false
  anonymous_pull_enabled = false

  # Premium-only hardening.
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
```

Runnable examples live in [`examples/basic`](examples/basic) (a Standard
registry plus its resource group) and [`examples/hardened`](examples/hardened)
(a Premium registry with public access, exports and untagged manifests locked
down). Both create their own resource group and generate a unique registry name,
so they can be applied as-is. Export `ARM_SUBSCRIPTION_ID` before running them —
the azurerm 4.x provider cannot configure itself without a subscription.

## SKU requirements

| Setting                                | Basic | Standard | Premium |
|----------------------------------------|:-----:|:--------:|:-------:|
| `anonymous_pull_enabled = true`        |  no   |   yes    |   yes   |
| `public_network_access_enabled = false`|  no   |    no    |   yes   |
| `export_policy_enabled = false`        |  no   |    no    |   yes   |
| `quarantine_policy_enabled = true`     |  no   |    no    |   yes   |
| `trust_policy_enabled = true`          |  no   |    no    |   yes   |
| `retention_policy_in_days`             |  no   |    no    |   yes   |

Azure additionally only accepts `export_policy_enabled = false` when
`public_network_access_enabled` is also `false`.

## Requirements

| Name      | Version         |
|-----------|-----------------|
| terraform | >= 1.5          |
| azurerm   | >= 4.0, < 5.0   |

The azurerm floor is 4.0 because `trust_policy_enabled` and
`retention_policy_in_days` do not exist before it — the last 3.x release
(3.117.1) still used the `trust_policy` and `retention_policy` blocks that 4.0
removed. The upper bound keeps a future 5.0 major from silently changing the
schema underneath consumers.

Running the test suite (`terraform test`) additionally needs Terraform >= 1.7
for `mock_provider`. That is a test-only requirement; consuming the module still
only needs 1.5.

## Inputs

| Name                            | Description                                                                                                | Type          | Default      | Required |
|---------------------------------|------------------------------------------------------------------------------------------------------------|---------------|--------------|:--------:|
| `name`                          | Name of the container registry. Globally unique, 5-50 alphanumeric characters.                              | `string`      | n/a          |   yes    |
| `resource_group_name`           | Name of the resource group in which to create the container registry.                                       | `string`      | n/a          |   yes    |
| `location`                      | Azure region in which to create the container registry.                                                     | `string`      | n/a          |   yes    |
| `sku`                           | SKU of the container registry. One of Basic, Standard or Premium.                                           | `string`      | `"Standard"` |    no    |
| `admin_enabled`                 | Whether the shared static admin username/password is enabled. Prefer Entra ID tokens.                       | `bool`        | `false`      |    no    |
| `public_network_access_enabled` | Whether the registry is reachable over the public internet. Premium only when set to `false`.               | `bool`        | `true`       |    no    |
| `anonymous_pull_enabled`        | Whether unauthenticated clients may pull. Standard or Premium only.                                         | `bool`        | `false`      |    no    |
| `export_policy_enabled`         | Whether artifacts may be exported. Premium only, and only disableable on a non-public registry.             | `bool`        | `true`       |    no    |
| `quarantine_policy_enabled`     | Whether pushed images are quarantined until scanned. Premium only.                                          | `bool`        | `false`      |    no    |
| `trust_policy_enabled`          | Whether content trust (signed image verification) is enforced. Premium only.                                | `bool`        | `false`      |    no    |
| `retention_policy_in_days`      | Days untagged manifests are kept before purge, 0-365. `null` leaves the policy disabled. Premium only.      | `number`      | `null`       |    no    |
| `tags`                          | Map of tags applied to the container registry.                                                              | `map(string)` | `{}`         |    no    |

## Outputs

| Name             | Description                                          |
|------------------|------------------------------------------------------|
| `id`             | ID of the container registry.                        |
| `name`           | Name of the container registry.                      |
| `login_server`   | URL used to log in with docker login.                |
| `admin_username` | Admin username, populated only when admin is enabled.|
| `admin_password` | Admin password (sensitive).                          |

## Development

```sh
terraform fmt -recursive
terraform init -backend=false && terraform validate
terraform test                      # no cloud credentials needed, providers are mocked
tflint --recursive
```

## License

[MIT](LICENSE)
