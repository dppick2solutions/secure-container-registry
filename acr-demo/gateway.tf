## -------------
## Application Gateway to front Container Instance
## -------------
resource "azurerm_public_ip" "public_ip" {
  name                = "ag-public-ip"
  location            = azurerm_resource_group.acr_demo.location
  resource_group_name = azurerm_resource_group.acr_demo.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

## -------------
## Application Gateway to front Container Instance
## -------------
resource "azurerm_application_gateway" "gateway" {
  name                = "appgateway"
  resource_group_name = azurerm_resource_group.acr_demo.name
  location            = azurerm_resource_group.acr_demo.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  frontend_port {
    name = "port-443"
    port = 443
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app_gateway.id]
  }

  frontend_ip_configuration {
    name                 = "fe-ipconfig"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = azurerm_subnet.ag_subnet.id
  }

  ssl_certificate {
    name                = "app_listener"
    key_vault_secret_id = azurerm_key_vault_certificate.gateway_cert.versionless_secret_id
  }

  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "fe-ipconfig"
    frontend_port_name             = "port-443"
    protocol                       = "Https"
    ssl_certificate_name           = "app_listener"
    host_names                     = ["hello-container.pick2solutions.cloud"]
  }

  backend_address_pool {
    name         = "container_group"
    ip_addresses = [azurerm_container_group.hello_world_container.ip_address]
  }

  backend_http_settings {
    name                  = "https"
    path                  = "/"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 60
    cookie_based_affinity = "Disabled"
  }

  request_routing_rule {
    name                       = "forward-to-container"
    priority                   = 1
    rule_type                  = "Basic"
    http_listener_name         = "https-listener"
    backend_address_pool_name  = "container_group"
    backend_http_settings_name = "https"
  }
}