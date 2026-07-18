output "id" {
  description = "ID of the container registry."
  value       = azurerm_container_registry.this.id
}

output "name" {
  description = "Name of the container registry."
  value       = azurerm_container_registry.this.name
}

output "login_server" {
  description = "URL used to log in to the container registry with docker login."
  value       = azurerm_container_registry.this.login_server
}

output "admin_username" {
  description = "Admin username, populated only when admin_enabled is true."
  value       = azurerm_container_registry.this.admin_username
}

output "admin_password" {
  description = "Admin password, populated only when admin_enabled is true."
  value       = azurerm_container_registry.this.admin_password
  sensitive   = true
}
