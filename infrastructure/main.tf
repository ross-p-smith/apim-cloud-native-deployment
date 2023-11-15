# The current logged in user will be the owner of the application
resource "azuread_application" "apim_app" {
  display_name = "apim_aso_app"
  owners       = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal" "apim_spn" {
  application_id = azuread_application.apim_app.application_id
  owners         = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal_password" "spn" {
  service_principal_id = azuread_service_principal.apim_spn.id
}

resource "azurerm_role_assignment" "sp_contributor" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.apim_spn.object_id
}

# Generate random resource group name
resource "random_pet" "rg_name" {
  prefix = var.prefix
}

resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = random_pet.rg_name.id
}

resource "random_pet" "azurerm_kubernetes_cluster_name" {
  prefix = "cluster"
}

resource "random_pet" "azurerm_kubernetes_cluster_dns_prefix" {
  prefix = "dns"
}

resource "random_pet" "azurerm_apim_name" {
  prefix = "apim"
}

################ AKS ################
resource "azurerm_kubernetes_cluster" "example" {
  name                = random_pet.azurerm_kubernetes_cluster_name.id
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = random_pet.azurerm_kubernetes_cluster_dns_prefix.id

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.example.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.example.kube_config_raw
  sensitive = true
}

################ APIM ################
resource "azurerm_api_management" "apim" {
  name                = random_pet.azurerm_apim_name.id
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  publisher_name      = "Company"
  publisher_email     = "company@terraform.io"
  sku_name            = "Developer_1"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = "la-${random_pet.azurerm_apim_name.id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "application_insights" {
  name                = "ai-${random_pet.azurerm_apim_name.id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.log_analytics_workspace.id
  application_type    = "web"
}

resource "azurerm_monitor_diagnostic_setting" "apim_diagnostic_setting" {
  name                       = "apimdiagnosticsetting"
  target_resource_id         = azurerm_api_management.apim.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id

  enabled_log {
    category_group = "allLogs"
  }

  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_key_vault" "key_vault" {
  name                = "kv-${random_pet.azurerm_apim_name.id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Purge"
    ]
  }

  network_acls {
    bypass         = "None"
    default_action = "Allow"
  }

  lifecycle {
    ignore_changes = [
      access_policy
    ]
  }
}

resource "azurerm_key_vault_secret" "application_insights_instrumentation_key" {
  name         = "kvs-aikey"
  value        = azurerm_application_insights.application_insights.instrumentation_key
  key_vault_id = azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_access_policy" "key_vault_apim_access_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id
  object_id    = azurerm_api_management.apim.identity[0].principal_id
  tenant_id    = azurerm_api_management.apim.identity[0].tenant_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

resource "azurerm_api_management_logger" "logger" {
  name                = "apim-logger"
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.rg.name
  resource_id         = azurerm_application_insights.application_insights.id

  application_insights {
    instrumentation_key = azurerm_application_insights.application_insights.instrumentation_key
  }
}