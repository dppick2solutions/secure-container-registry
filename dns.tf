## -------------
## Reference to DNS Zone
## -------------
data "azurerm_dns_zone" "pick2cloud" {
  name                = "pick2solutions.cloud"
  resource_group_name = "dns"
}

resource "azurerm_dns_a_record" "hello_container" {
  name                = "hello-container"
  zone_name           = data.azurerm_dns_zone.pick2cloud.name
  resource_group_name = "dns"
  ttl                 = 300
  records             = [azurerm_public_ip.public_ip.ip_address]
}