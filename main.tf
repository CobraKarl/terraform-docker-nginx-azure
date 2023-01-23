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
  client_id       = var.clientId
  client_secret   = var.clientSecret
  tenant_id       = var.tenantId
  features {

  }
}




resource "azurerm_resource_group" "rg" {
  name     = var.RGName
  location = var.location

}

resource "azurerm_storage_account" "storage" {
  name                     = "azstorage${var.RGName}"
  resource_group_name      = var.RGName
  location                 = var.location
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



resource "azurerm_container_registry" "acr" {
  name                = "containerregistry${var.RGName}"
  resource_group_name = var.RGName
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
  depends_on = [
    azurerm_resource_group.rg
  ]


}


resource "azurerm_app_service_plan" "asp" {
  name                = "asp${var.RGName}"
  resource_group_name = var.RGName
  location            = var.location
  kind                = "Linux"
  reserved            = true
  sku {
    tier = "Standard"
    size = "S1"

  }
  depends_on = [
    azurerm_resource_group.rg,
    azurerm_container_registry.acr
  ]

}


resource "azurerm_app_service" "app" {
  name                = "web${var.RGName}"
  resource_group_name = var.RGName
  location            = var.location
  app_service_plan_id = azurerm_app_service_plan.asp.id
  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL"          = azurerm_container_registry.acr.login_server
    "DOCKER_REGISTRY_SERVER_USERNAME"     = azurerm_container_registry.acr.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = azurerm_container_registry.acr.admin_password


  }
  site_config {
    linux_fx_version = "DOCKER|${azurerm_container_registry.acr.name}/mkk:latest"

  }
  identity {
    type = "SystemAssigned"
  }
  depends_on = [
    azurerm_container_registry.acr
  ]


}











