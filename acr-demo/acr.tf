resource "azurerm_resource_group" "acr_demo" {
  name     = "acr_demo_rg"
  location = "East US"
}

resource "azurerm_container_registry" "acr" {
  name                          = "Pick2ContainerRegistryDemo"
  resource_group_name           = azurerm_resource_group.acr_demo.name
  location                      = azurerm_resource_group.acr_demo.location
  sku                           = "Premium"
  public_network_access_enabled = false
}