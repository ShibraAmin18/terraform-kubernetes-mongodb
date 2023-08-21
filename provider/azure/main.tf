data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

data "azurerm_subscription" "primary" {}

resource "azurerm_key_vault" "mongo-secret" {
  name                        = format("%s-%s-%s", var.mongodb_config.environment, var.mongodb_config.name, "mongodb")
  resource_group_name         = var.resource_group_name
  location                    = var.resource_group_location
  sku_name                    = "standard"
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    key_permissions = [
      "Get",
      "List",
    ]
    secret_permissions = [
      "Set",
      "Get",
      "List",
      "Delete",
      "Purge",
    ]
  }
}

resource "azurerm_key_vault_secret" "mongo-secret" {
  name = format("%s-%s-%s", var.mongodb_config.environment, var.mongodb_config.name, "secret")
  value = var.mongodb_custom_credentials_enabled ? jsonencode(
    {
      "root_user" : "${var.mongodb_custom_credentials_config.root_user}",
      "root_password" : "${var.mongodb_custom_credentials_config.root_password}",
      "metric_exporter_user" : "${var.mongodb_custom_credentials_config.metric_exporter_user}",
      "metric_exporter_password" : "${var.mongodb_custom_credentials_config.metric_exporter_password}"
    }) : jsonencode(
    {
      "root_user" : "root",
      "root_password" : "${var.root_password}",
      "metric_exporter_user" : "mongodb_exporter",
      "metric_exporter_password" : "${var.metric_exporter_pasword}"
  })
  content_type = "application/json"
  key_vault_id = azurerm_key_vault.mongo-secret.id
}

resource "azurerm_user_assigned_identity" "mongo_backup" {
  name                = "mongo-backup"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
}

resource "azurerm_key_vault_access_policy" "secretadmin_backup" {
  key_vault_id = azurerm_key_vault.mongo-secret.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.mongo_backup.principal_id

  secret_permissions = [
    "Get",
    "List",
    "Delete",
  ]
}

resource "azurerm_user_assigned_identity" "pod_identity_backup" {
  name                = format("%s-%s-%s", var.mongodb_config.environment, var.mongodb_config.name, "pod-identity-backup")
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
}

resource "azurerm_key_vault_access_policy" "pod_identity_backup" {
  key_vault_id = azurerm_key_vault.mongo-secret.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.pod_identity_backup.principal_id

  secret_permissions = [
    "Get",
    "List",
    "Delete",
  ]
}

resource "azurerm_user_assigned_identity" "mongo_restore" {
  name                = format("%s-%s-%s", var.mongodb_config.environment, var.mongodb_config.name, "mongo-restore")
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
}

resource "azurerm_key_vault_access_policy" "secretadmin_restore" {
  key_vault_id = azurerm_key_vault.mongo-secret.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.mongo_restore.principal_id

  secret_permissions = [
    "Get",
    "List",
    "Delete",
  ]
}

resource "azurerm_user_assigned_identity" "pod_identity_restore" {
  name                = format("%s-%s-%s", var.mongodb_config.environment, var.mongodb_config.name, "pod-identity-restore")
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
}

resource "azurerm_key_vault_access_policy" "pod_identity_restore" {
  key_vault_id = azurerm_key_vault.mongo-secret.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.pod_identity_restore.principal_id

  secret_permissions = [
    "Get",
    "List",
    "Delete",
  ]
}

output "service_account_backup" {
  value       = azurerm_user_assigned_identity.mongo_backup.client_id
  description = "Azure User Assigned Identity for backup"
}

output "service_account_restore" {
  value       = azurerm_user_assigned_identity.mongo_restore.client_id
  description = "Azure User Assigned Identity for restore"
}