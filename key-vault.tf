resource "random_string" "kv" {
  length  = 2
  special = false
  numeric = true
}

#-------------------------------------------------
# Keyvault Creation - Default is "true"
#-------------------------------------------------
resource "azurerm_key_vault" "main" {
  #checkov:skip=CKV_AZURE_110
  #checkov:skip=CKV_AZURE_42
  name                            = lower(format("%s%s", substr(var.key_vault_name, 0, 22), random_string.kv.result))
  location                        = var.location
  resource_group_name             = var.resource_group_name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = var.key_vault_sku_pricing_tier
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  soft_delete_retention_days      = 7 #var.soft_delete_retention_days
  enable_rbac_authorization       = var.enable_rbac_authorization
  purge_protection_enabled        = var.enable_purge_protection
  public_network_access_enabled   = var.public_network_access_enabled
  tags                            = merge({ "ResourceName" = var.key_vault_name }, var.tags, )

  dynamic "network_acls" {
    for_each = var.network_acls != null ? [true] : []
    content {
      bypass                     = var.network_acls.bypass
      default_action             = var.network_acls.default_action
      ip_rules                   = var.network_acls.ip_rules
      virtual_network_subnet_ids = var.network_acls.virtual_network_subnet_ids
    }
  }

  dynamic "access_policy" {
    for_each = local.combined_access_policies
    content {
      certificate_permissions = access_policy.value.certificate_permissions
      key_permissions         = access_policy.value.key_permissions
      object_id               = access_policy.value.object_id
      secret_permissions      = access_policy.value.secret_permissions
      storage_permissions     = access_policy.value.storage_permissions
      tenant_id               = data.azurerm_client_config.current.tenant_id
    }
  }

  dynamic "contact" {
    for_each = var.certificate_contacts
    content {
      email = contact.value.email
      name  = contact.value.name
      phone = contact.value.phone
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

#-----------------------------------------------------------------------------------
# Keyvault Secret - Random password Creation if value is empty - Default is "false"
#-----------------------------------------------------------------------------------

resource "random_password" "passwd" {
  for_each    = { for k, v in var.secrets : k => v if v == "" }
  length      = var.random_password_length
  min_upper   = 4
  min_lower   = 2
  min_numeric = 4
  min_special = 4

  keepers = {
    name = each.key
  }
}

resource "azurerm_key_vault_secret" "keys" {
  for_each        = var.secrets
  name            = each.key
  value           = each.value != "" ? each.value : random_password.passwd[each.key].result
  key_vault_id    = azurerm_key_vault.main.id
  content_type    = "key"
  expiration_date = "2024-12-31T20:00:00Z"

  lifecycle {
    ignore_changes = [
      tags,
      value
    ]
  }
}

#---------------------------------------------------
# azurerm monitoring diagnostics - KeyVault
#---------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "diag" {
  count                      = var.log_analytics_workspace_id != null ? 1 : 0
  name                       = lower(format("%s-diag", azurerm_key_vault.main.name))
  target_resource_id         = azurerm_key_vault.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  storage_account_id         = var.storage_account_id != null ? var.storage_account_id : null

  dynamic "log" {
    for_each = var.kv_diag_logs
    content {
      category = log.value
      enabled  = true
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true
    }
  }
}
