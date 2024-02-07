resource "azurerm_user_assigned_identity" "container" {
  location            = azurerm_resource_group.acr_demo.location
  name                = "container-group"
  resource_group_name = azurerm_resource_group.acr_demo.name
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.container.principal_id
}