terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0"
    }
  }

  # Update this block with the location of your terraform state file
  backend "azurerm" {
    resource_group_name  = "rg-github-deploy-tf"
    storage_account_name = "sagithubdeploytf"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" {
  features {}
  use_oidc                   = true
  skip_provider_registration = true
}

# Resource group data call
data "azurerm_resource_group" "rg" {
  name = "rg-github-deploy-tf"
}

# Test resource
resource "azurerm_storage_account" "test_sa" {
  account_replication_type = "GRS"
  account_tier             = "Standard"
  location                 = "australiaeast"
  name                     = "sanstestaccount01"
  resource_group_name      = data.azurerm_resource_group.rg.name

  # Security additions
  min_tls_version = "TLS1_2"
  queue_properties {
    logging {
      delete  = true
      read    = true
      write   = true
      version = 1.0
    }
  }
  public_network_access_enabled = false

}

resource "azurerm_log_analytics_workspace" "test_la" {
  name                = "la-ns-testws01"
  location            = "australiaeast"
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 7
}
