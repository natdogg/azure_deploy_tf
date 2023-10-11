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

module "core_infrastructure" {
  source = "./modules/core"

  tenant_id      = data.azurerm_client_config.current.tenant_id
  resource_group = data.azurerm_resource_group.rg
}
