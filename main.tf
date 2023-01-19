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

resource "azurerm_storage_account" "storage" {
    name = "azstorage"
    resource_group_name = var.RGName
    location = var.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
    allow_blob_public_access = true
    depends_on = [
      azurerm_resource_group.rg
    ]

}

resource "azurerm_storage_container" "container" {
  name                  = "container1"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "blob"
  depends_on = [
    azurerm_storage_account.storage
  ]

}

resource "azurerm_container_registry" "container_registry" {
    name = "containerregistry"
    resource_group_name = var.RGName
    location = var.location
    sku = "Basic"
    admin_enabled = true
    depends_on = [
      azurerm_resource_group.rg
    ] 
}

