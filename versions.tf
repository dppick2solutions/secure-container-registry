terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90.0"
    }
  }
  # configure azure blob storage as state backend
  backend "azurerm" {}
  required_version = "~> 1.7.2"
}

provider "azurerm" {
  client_id = var.client_id
  tenant_id = var.tenant_id
  use_oidc  = true
  features {}
}