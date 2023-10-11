resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-github-01"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "vnet_subnet1" {
  name                 = "subnet1"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "nsg_subnet1" {
  name                = "nsg-subnet1"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
}

resource "azurerm_subnet_network_security_group_association" "nsg_subnet1_association" {
  network_security_group_id = azurerm_network_security_group.nsg_subnet1.id
  subnet_id                 = azurerm_subnet.vnet_subnet1.id
}

resource "azurerm_log_analytics_workspace" "test_la" {
  name                = "la-ns-testws01"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  sku                 = "PerGB2018"
}

resource "azurerm_private_endpoint" "kv_pe" {
  name                = "pe-la-ns-testws01"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
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
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  sku_name            = "standard"
  tenant_id           = var.tenant_id

  public_network_access_enabled = false
  purge_protection_enabled      = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}
