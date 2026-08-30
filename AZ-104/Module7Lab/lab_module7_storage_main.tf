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
resource "azurerm_resource_group" "storage_rg" {
  name     = "rg-az104-module7-storage"
  location = "westeurope"

  tags = {
    Environment = "Production"
    Module      = "AZ104-Module07-StorageAccounts"
    ManagedBy   = "Terraform"
  }
}

# 2. Virtual Network ve Subnet (Güvenlik Duvarı Kısıtlaması İçin)
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-storage-sec-westeurope"
  location            = azurerm_resource_group.storage_rg.location
  resource_group_name = azurerm_resource_group.storage_rg.name
  address_space       = ["10.70.0.0/16"]
}

resource "azurerm_subnet" "app_subnet" {
  name                 = "snet-app-services"
  resource_group_name  = azurerm_resource_group.storage_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.70.1.0/24"]

  # Service Endpoints Etkinleştiriliyor
  service_endpoints = ["Microsoft.Storage"]
}

# 3. Azure Storage Account (GPv2 / GRS / Secure)
resource "azurerm_storage_account" "main_storage" {
  name                     = "staz104mod07prod2026" # Benzersiz olmalıdır
  resource_group_name      = azurerm_resource_group.storage_rg.name
  location                 = azurerm_resource_group.storage_rg.location
  account_tier             = "Standard"
  account_kind             = "StorageV2" # General Purpose v2
  account_replication_type = "GRS"       # Geo-Redundant Storage

  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"

  # Ağ Güvenlik Duvarı Kuralları
  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["203.0.113.5"] # İzin verilen harici Public IP
    virtual_network_subnet_ids = [azurerm_subnet.app_subnet.id]
    bypass                     = ["AzureServices", "Logging", "Metrics"]
  }

  tags = {
    DataClassification = "Confidential"
  }
}

# 4. Blob Container Oluşturma
resource "azurerm_storage_container" "documents_container" {
  name                  = "corporate-documents"
  storage_account_name  = azurerm_storage_account.main_storage.name
  container_access_type = "private" # Yetkisiz kamu erişimine kapalı
}

# Outputs
output "storage_account_name" {
  value = azurerm_storage_account.main_storage.name
}

output "primary_blob_endpoint" {
  value = azurerm_storage_account.main_storage.primary_blob_endpoint
}

output "secondary_blob_endpoint" {
  value = azurerm_storage_account.main_storage.secondary_blob_endpoint
}