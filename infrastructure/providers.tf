terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.67.0"
    }
    azuread= {
      source  = "hashicorp/azuread"
      version = "~> 2.41.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }    
  }

  required_version = ">=1.0"
}

provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

provider "azuread" {
}

# Configure a Service Principal so that we can access the APIM in the different Resource Groups
data "azurerm_client_config" "current" {}