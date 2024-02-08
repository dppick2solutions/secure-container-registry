resource "azurerm_log_analytics_workspace" "logs" {
  name                = "acrdemologs"
  location            = azurerm_resource_group.acr_demo.location
  resource_group_name = azurerm_resource_group.acr_demo.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}