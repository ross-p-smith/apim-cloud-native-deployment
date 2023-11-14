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
