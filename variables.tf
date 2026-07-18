variable "name" {
  description = "Name of the container registry. Must be globally unique, 5-50 alphanumeric characters."
  type        = string
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
}

variable "admin_enabled" {
  description = "Whether the admin user with a static username and password is enabled."
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Whether the container registry is reachable over the public internet."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Map of tags applied to the container registry."
  type        = map(string)
  default     = {}
}
