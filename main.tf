terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0"
    }
  }

  # Update this block with the location of your terraform state file
  backend "azurerm" {
    resource_group_name  = "rg-github-deploy01"
    storage_account_name = "sansterraformgithubactions"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
}

# Resource group data call
data "azurerm_resource_group" "rg" {
    name = "rg-github-deploy01"
}

# Test resource
resource "azurerm_storage_account" "test_sa" {
    account_replication_type = "LRS"
    account_tier = "Standard"
    location = "australiaeast"
    name = "sanstestaccount01"
    resource_group_name = data.azurerm_resource_group.rg.name  
}