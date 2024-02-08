## -------------
## Resource Group
## -------------
resource "azurerm_resource_group" "acr_demo" {
  name     = "acr_demo_rg"
  location = "East US"
}

## -------------
## Azure Container Registry
## -------------
resource "azurerm_container_registry" "acr" {
  name                          = "Pick2ContainerRegistryDemo"
  resource_group_name           = azurerm_resource_group.acr_demo.name
  location                      = azurerm_resource_group.acr_demo.location
  sku                           = "Premium"
  public_network_access_enabled = true #Note that in a production environment, you'd want this to be false.
  network_rule_set {
    default_action = "Deny"
    ip_rule {
      action   = "Allow"
      ip_range = "${var.local_ip}/32"
    }
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.container.id]
  }
}