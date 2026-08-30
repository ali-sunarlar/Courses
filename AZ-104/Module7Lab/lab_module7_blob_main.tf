terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.70.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# 1. Kaynak Grubu
resource "azurerm_resource_group" "blob_rg" {
  name     = "rg-az104-module7-blob"
  location = "westeurope"

  tags = {
    Environment = "Production"
    Module      = "AZ104-Module07-BlobStorage"
    ManagedBy   = "Terraform"
  }
}

# 2. Storage Account (GPv2 / LRS)
resource "azurerm_storage_account" "media_storage" {
  name                     = "staz104mod07media2026"
  resource_group_name      = azurerm_resource_group.blob_rg.name
  location                 = azurerm_resource_group.blob_rg.location
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
  access_tier              = "Hot" # Varsayılan Hot katmanı

  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
}

# 3. Blob Container Oluşturma
resource "azurerm_storage_container" "media_container" {
  name                  = "video-library"
  storage_account_name  = azurerm_storage_account.media_storage.name
  container_access_type = "private"
}

# 4. Storage Management Policy (Yaşam Döngüsü Yönetimi / Lifecycle Management)
resource "azurerm_storage_management_policy" "lifecycle_policy" {
  storage_account_id = azurerm_storage_account.media_storage.id

  rule {
    name    = "media-lifecycle-rule"
    enabled = true

    filters {
      prefix_match = ["video-library/"]
      blob_types   = ["blockBlob"]
    }

    actions {
      base_blob {
        # 30 gün boyunca erişilmeyen veriyi Cool katmanına taşı
        tier_to_cool_after_days_since_modification_greater_than = 30

        # 90 gün boyunca erişilmeyen veriyi Archive katmanına taşı
        tier_to_archive_after_days_since_modification_greater_than = 90

        # 365 gün sonra veriyi tamamen sil
        delete_after_days_since_modification_greater_than = 365
      }
      snapshot {
        delete_after_days_since_modification_greater_than = 30
      }
    }
  }
}

# Outputs
output "storage_account_name" {
  value = azurerm_storage_account.media_storage.name
}

output "blob_container_name" {
  value = azurerm_storage_container.media_container.name
}