output "azure_subscription_id" {
  description = "Azure Subscription ID."
  value       = data.azurerm_client_config.current.subscription_id
}

output "azure_tenant_id" {
  description = "Azure Tenant ID."
  value       = data.azurerm_client_config.current.tenant_id
}

output "apim_client_id" {
  description = "APIM Client ID."
  value       = azuread_application.apim_app.application_id
}

output "apim_client_secret" {
  description = "APIM Client Secret."
  value       = azuread_service_principal_password.spn.value
  sensitive   = true
}

