variable "ARM_CLIENT_ID" {}
variable "ARM_CLIENT_SECRET" {}
variable "DJANGO_SECRET_KEY_PROD" {}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.68.0"
    }
  }
  backend "azurerm" {
    resource_group_name = "rg-acmp-final"
    storage_account_name = "acmp2400storageaccount"
    container_name = "big-tf-state-acmp2400"
    use_azuread_auth = true
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_container_registry" "jtorres_acr" {
  name                = "jtorresacmp2400"
  resource_group_name = "rg-jtorres19"
  location            = "Central US"
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_container_group" "jtorres-aci" {
  name                = "acmp-jtorres-aci"
  location            = "Central US"
  resource_group_name = "rg-jtorres19"
  ip_address_type     = "Public"
  dns_name_label      = "acmp-jtorres-instance"
  os_type             = "Linux"

  container {
    name   = "final"
    image  = "jtorresacmp2400.azurecr.io/final:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 8000
      protocol = "TCP"
    }
  
    secure_environment_variables = {
      DJANGO_SECRET_KEY = var.DJANGO_SECRET_KEY_PROD
    }
  }
  image_registry_credential {
    server = "jtorresacmp2400.azurecr.io"
    username = var.ARM_CLIENT_ID
    password = var.ARM_CLIENT_SECRET
  }
  }
