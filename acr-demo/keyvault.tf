## -------------
## ACME Bot Azure Function
## -------------
data "azurerm_windows_function_app" "acme" {
  name                = "func-pick2acmebot-wjxf"
  resource_group_name = "dns"
}

## -------------
## Azure Key Vault
## -------------
resource "azurerm_key_vault" "certificate_vault" {
  name                        = "pick2acrdemo"
  location                    = azurerm_resource_group.acr_demo.location
  resource_group_name         = azurerm_resource_group.acr_demo.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 90
  purge_protection_enabled    = true
  sku_name                    = "standard"
  enable_rbac_authorization   = true
  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    virtual_network_subnet_ids = [
      azurerm_subnet.kv_subnet.id,
    ]
    ip_rules = concat([
      var.local_ip
    ], data.azurerm_windows_function_app.acme.outbound_ip_address_list)
  }
}

## -------------
## Certificate for App Gateway
## -------------
resource "azurerm_key_vault_certificate" "gateway_cert" {
  name         = "app-gateway-cert"
  key_vault_id = azurerm_key_vault.certificate_vault.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }
    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }
    lifetime_action {
      action {
        action_type = "AutoRenew"
      }
      trigger {
        days_before_expiry = 30
      }
    }
    secret_properties {
      content_type = "application/x-pkcs12"
    }
    x509_certificate_properties {
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]
      subject_alternative_names {
        dns_names = ["hello-container.pick2solutions.cloud"]
      }
      subject            = "CN=hello-container.pick2solutions.cloud"
      validity_in_months = 12
    }
  }
  lifecycle {
    ignore_changes = all #terraform will do a onetime provision of this certificate. after that, it will be managed by certbot.
  }
}