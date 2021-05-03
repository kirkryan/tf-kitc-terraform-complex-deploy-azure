# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "kitc-multiplayer-snake" {
  name     = "kitc-multiplayer-snake"
  location = "North Europe"
  tags = {
    "environment" = "demo"
  }
}

# Azure App Service Plan
resource "azurerm_app_service_plan" "kitc-multiplayer-snake-sp" {
  name                = "kitc-multiplayer-snake"
  location            = azurerm_resource_group.kitc-multiplayer-snake.location
  resource_group_name = azurerm_resource_group.kitc-multiplayer-snake.name
  kind                = "Linux"
  reserved            = true # Required to set linux_fx_version (https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service#linux_fx_version)

  sku {
    tier = "Basic" # "Dynamic" can be used for shared/consumption plan
    size = "B1"
  }

  tags = {
    "environment" = "demo"
  }
}

# Azure App Service
resource "azurerm_app_service" "kitc-snake-app" {
  name                = "kitc-snake-app-service"
  location            = azurerm_resource_group.kitc-multiplayer-snake.location
  resource_group_name = azurerm_resource_group.kitc-multiplayer-snake.name
  app_service_plan_id = azurerm_app_service_plan.kitc-multiplayer-snake-sp.id
  
  site_config {
    app_command_line = "npm start"
    linux_fx_version = "DOCKER|lonespear/kitc-snake:latest" 
  }
  
  tags = {
    "environment" = "demo"
  }
}

output "multiplayer_url" {
  value = azurerm_app_service.kitc-snake-app.default_site_hostname
  description = "The URL that our surprise will be available on"
}