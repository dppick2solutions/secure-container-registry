## -------------
## Virtual Network
## -------------
resource "azurerm_virtual_network" "acr_demo" {
  name                = "acr-demo-vnet"
  location            = azurerm_resource_group.acr_demo.location
  resource_group_name = azurerm_resource_group.acr_demo.name
  address_space       = [local.vnet_address_cidr]
}

## -------------
## Private DNS Zone (ACR)
## -------------
resource "azurerm_private_dns_zone" "acr_private_dns" {
  name                = "privatelink.azurecr.ioeastus.data.privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.acr_demo.name
}
## -------------
## Private DNS Zone (AKV)
## -------------
resource "azurerm_private_dns_zone" "akv_private_dns" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.acr_demo.name
}

## -------------
## Subnet for Container Group
## -------------
resource "azurerm_subnet" "container_group_subnet" {
  name                 = "conatiner-instances"
  resource_group_name  = azurerm_resource_group.acr_demo.name
  virtual_network_name = azurerm_virtual_network.acr_demo.name
  address_prefixes     = [local.container_group_subnet_cidr]

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

## -------------
## Subnet for PE to ACR
## -------------
resource "azurerm_subnet" "acr_subnet" {
  name                                           = "azurecontainerregistry"
  resource_group_name                            = azurerm_resource_group.acr_demo.name
  virtual_network_name                           = azurerm_virtual_network.acr_demo.name
  address_prefixes                               = [local.acr_pe_cidr]
  service_endpoints                              = ["Microsoft.ContainerRegistry"]
  enforce_private_link_endpoint_network_policies = true
}

## -------------
## Subnet for PE to KV
## -------------
resource "azurerm_subnet" "kv_subnet" {
  name                                           = "azurekeyvault"
  resource_group_name                            = azurerm_resource_group.acr_demo.name
  virtual_network_name                           = azurerm_virtual_network.acr_demo.name
  address_prefixes                               = [local.kv_pe_cidr]
  service_endpoints                              = ["Microsoft.KeyVault"]
  enforce_private_link_endpoint_network_policies = true
}

## -------------
## Subnet for AppGateway
## -------------
resource "azurerm_subnet" "ag_subnet" {
  name                                           = "appgateway"
  resource_group_name                            = azurerm_resource_group.acr_demo.name
  virtual_network_name                           = azurerm_virtual_network.acr_demo.name
  address_prefixes                               = [local.app_gateway_cidr]
  service_endpoints                              = ["Microsoft.KeyVault"]
  enforce_private_link_endpoint_network_policies = true
}


## -------------
## Private Endpoint to ACR
## -------------
resource "azurerm_private_endpoint" "acr_private_endpoint" {
  name                = "acr_pe"
  location            = azurerm_resource_group.acr_demo.location
  resource_group_name = azurerm_resource_group.acr_demo.name
  subnet_id           = azurerm_subnet.acr_subnet.id
  private_dns_zone_group {
    name                 = "acrprivatedns"
    private_dns_zone_ids = [azurerm_private_dns_zone.acr_private_dns.id]
  }
  private_service_connection {
    name                           = "acr_psc"
    private_connection_resource_id = azurerm_container_registry.acr.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }
}

## -------------
## Private Endpoint to AKV
## -------------
resource "azurerm_private_endpoint" "akv_private_endpoint" {
  name                = "akv_pe"
  location            = azurerm_resource_group.acr_demo.location
  resource_group_name = azurerm_resource_group.acr_demo.name
  subnet_id           = azurerm_subnet.acr_subnet.id
  private_dns_zone_group {
    name                 = "akvprivatedns"
    private_dns_zone_ids = [azurerm_private_dns_zone.akv_private_dns.id]
  }
  private_service_connection {
    name                           = "akv_psc"
    private_connection_resource_id = azurerm_key_vault.certificate_vault.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
}