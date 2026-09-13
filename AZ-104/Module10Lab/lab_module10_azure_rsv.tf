#Aşağıdaki HCL kodu; Geo-Redundant (GRS) depolama tipinde bir **Recovery Services Vault**, günlük yedekleme yapan bir **Backup Policy** ve bir **Azure File Share** yedekleme koruma tanımını dağıtmaktadır:
# Kaynak Grubu
resource "azurerm_resource_group" "rg" {
  name     = "rg-backup-prod"
  location = "westeurope"
}

# Recovery Services Vault (GRS Kasa)
resource "azurerm_recovery_services_vault" "vault" {
  name                = "rsv-prod-westeurope"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  storage_mode_type   = "GeoRedundant" # GRS Yedeklilik
}

# Azure File Share için Yedekleme Politikası (Backup Policy)
resource "azurerm_backup_policy_file_share" "policy" {
  name                = "policy-fileshare-daily"
  resource_group_name = azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 30 # 30 Günlük Saklama
  }
}

# Depolama Hesabı ve File Share
resource "azurerm_storage_account" "sa" {
  name                     = "stcompliancefiles2026"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "share" {
  name                 = "compliance-data"
  storage_account_name = azurerm_storage_account.sa.name
  quota                = 500
}

# File Share'i Recovery Services Vault ile Korumaya Alma
resource "azurerm_backup_container_storage_account" "container" {
  resource_group_name = azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  storage_account_id  = azurerm_storage_account.sa.id
}

resource "azurerm_backup_protected_file_share" "protected_share" {
  resource_group_name       = azurerm_resource_group.rg.name
  recovery_vault_name       = azurerm_recovery_services_vault.vault.name
  source_storage_account_id = azurerm_backup_container_storage_account.container.storage_account_id
  source_file_share_name    = azurerm_storage_share.share.name
  backup_policy_id          = azurerm_backup_policy_file_share.policy.id
}