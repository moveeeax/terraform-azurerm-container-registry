variable "name" {
  description = "Name of the container registry. Must be globally unique, 5-50 alphanumeric characters."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.name))
    error_message = "name must be 5-50 alphanumeric characters; hyphens, underscores and dots are not allowed in an ACR name."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group in which to create the container registry."
  type        = string
}

variable "location" {
  description = "Azure region in which to create the container registry."
  type        = string
}

variable "sku" {
  description = "SKU of the container registry. One of Basic, Standard or Premium."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "sku must be one of Basic, Standard or Premium."
  }
}

variable "admin_enabled" {
  description = "Whether the admin user with a static username and password is enabled. Leave disabled and use Entra ID (Azure AD) tokens instead; the admin account is a single shared credential that cannot be scoped or attributed to a caller."
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Whether the container registry is reachable over the public internet. Setting this to false requires the Premium SKU."
  type        = bool
  default     = true
}

variable "anonymous_pull_enabled" {
  description = "Whether unauthenticated clients may pull from the registry. Requires the Standard or Premium SKU. Keep this false unless the registry is deliberately publishing public images."
  type        = bool
  default     = false
}

variable "export_policy_enabled" {
  description = "Whether artifacts may be exported out of the registry. Requires the Premium SKU to disable, and Azure only accepts export_policy_enabled = false when public_network_access_enabled is also false."
  type        = bool
  default     = true
}

variable "quarantine_policy_enabled" {
  description = "Whether pushed images are quarantined until they pass a scan. Requires the Premium SKU."
  type        = bool
  default     = false
}

variable "trust_policy_enabled" {
  description = "Whether content trust (signed image verification) is enforced. Requires the Premium SKU."
  type        = bool
  default     = false
}

variable "retention_policy_in_days" {
  description = "Number of days untagged manifests are kept before being purged. Null leaves the retention policy disabled. Requires the Premium SKU."
  type        = number
  default     = null

  validation {
    condition     = var.retention_policy_in_days == null || try(var.retention_policy_in_days >= 0 && var.retention_policy_in_days <= 365 && floor(var.retention_policy_in_days) == var.retention_policy_in_days, false)
    error_message = "retention_policy_in_days must be a whole number between 0 and 365, or null to leave the policy disabled."
  }
}

variable "tags" {
  description = "Map of tags applied to the container registry."
  type        = map(string)
  default     = {}
}
