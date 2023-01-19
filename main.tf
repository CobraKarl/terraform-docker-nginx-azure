terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.91.0"
    }
  }
}

provider "azurerm" {
    subscription_id = var.subscriptionId
    client_id = var.clientId
    client_secret = var.clientSecret
    tenant_id = var.tenantId
  features {

  }
}

resource "azurerm_resource_group" "rg" {
    name = var.RGName
    location = var.location
  
}