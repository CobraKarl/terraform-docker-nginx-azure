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

resource "azurerm_container_registry" "container_registry" {
  name                = "containerregistry${var.RGName}"
  resource_group_name = var.RGName
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
  depends_on = [
    azurerm_resource_group.rg
  ]

}

resource "azurerm_container_registry_task" "build" {
  name                  = "buildmkk2"
  container_registry_id = azurerm_container_registry.container_registry.id
  platform {
    os = "Linux"
  }
  docker_step {
    dockerfile_path      = "./Dockerfile"
    # context_path         = https://appmkk2000.azurewebsites.net/"
    image_names = [ "mkk2" ]
    # target = "mkk2"
    
    
    context_access_token = "p9gfA+v/8b6jsMSarb/1mtAxz6+XQsQPMgU8lazU10+ACRB5DQZJ"
  }

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

}

resource "azurerm_app_service" "app" {
  name                = "app${var.RGName}"
  resource_group_name = var.RGName
  location            = var.location
  app_service_plan_id = azurerm_app_service_plan.asp.id
  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL"          = "containerregistrymkk2000.azurecr.io"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = "containerregistrymkk2000"
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = "p9gfA+v/8b6jsMSarb/1mtAxz6+XQsQPMgU8lazU10+ACRB5DQZJ"


  }
  site_config {
    linux_fx_version = "DOCKER|containerregistrymkk2000.azurecr.io/mkk:latest"

  }
  identity {
    type = "SystemAssigned"
  }


}





