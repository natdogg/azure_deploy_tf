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

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-github-01"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "vnet_subnet1" {
  name                 = "subnet1"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "nsg_subnet1" {
  name                = "nsg-subnet1"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_subnet_network_security_group_association" "nsg_subnet1_association" {
  network_security_group_id = azurerm_network_security_group.nsg_subnet1.id
  subnet_id                 = azurerm_subnet.vnet_subnet1.id
}

resource "azurerm_log_analytics_workspace" "test_la" {
  name                = "la-ns-testws01"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
}

resource "azurerm_private_endpoint" "kv_pe" {
  name                = "pe-la-ns-testws01"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.vnet_subnet1.id

  private_service_connection {
    name                           = "psc-la-ns-testws01"
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
}

resource "azurerm_key_vault" "kv" {
  name                = "kv-ns-testkv02"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  public_network_access_enabled = false
  purge_protection_enabled      = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}
