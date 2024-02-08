## -------------
## User Assigned Managed Identity for Container Instance
## -------------
resource "azurerm_user_assigned_identity" "container" {
  location            = azurerm_resource_group.acr_demo.location
  name                = "container-group"
  resource_group_name = azurerm_resource_group.acr_demo.name
}

## -------------
## User Assigned Managed Identity for Container Instance
## -------------
resource "azurerm_user_assigned_identity" "app_gateway" {
  location            = azurerm_resource_group.acr_demo.location
  name                = "app-gateway"
  resource_group_name = azurerm_resource_group.acr_demo.name
}

## -------------
## Assign UAMI to ACR Pull role on the registry.
## -------------
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.container.principal_id
}

## -------------
## Assign UAMI to Key Vault Admin.
## -------------
resource "azurerm_role_assignment" "kv_certs" {
  scope                = azurerm_key_vault.certificate_vault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azurerm_user_assigned_identity.app_gateway.principal_id
}

data "azurerm_client_config" "current" {}
