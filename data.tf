# Resource group data call
data "azurerm_resource_group" "rg" {
  name = "rg-github-deploy-tf"
}

# Tenant data call
data "azurerm_client_config" "current" {}