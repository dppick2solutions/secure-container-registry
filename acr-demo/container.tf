resource "azurerm_container_group" "hello_world_container" {
  name                = "hello-world-container"
  location            = azurerm_resource_group.acr_demo.location
  resource_group_name = azurerm_resource_group.acr_demo.name
  ip_address_type     = "Private"
  os_type             = "Linux"
  subnet_ids          = [azurerm_subnet.container_group_subnet.id]
  container {
    name   = "hello-world"
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 443
      protocol = "TCP"
    }
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.container.id]
  }
  image_registry_credential {
    user_assigned_identity_id = azurerm_user_assigned_identity.container.id
    server                    = "pick2containerregistrydemo.eastus.data.azurecr.io"
  }
}