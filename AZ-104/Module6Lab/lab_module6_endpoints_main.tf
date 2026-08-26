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
resource "azurerm_resource_group" "endpoints_rg" {
  name     = "rg-az104-module6-endpoints"
  location = "westeurope"

  tags = {
    Environment = "Production"
    Module      = "AZ104-Module06-Endpoints"
    ManagedBy   = "Terraform"
  }
}

# 2. Virtual Network ve Subnet'ler
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-secure-westeurope"
  location            = azurerm_resource_group.endpoints_rg.location
  resource_group_name = azurerm_resource_group.endpoints_rg.name
  address_space       = ["10.50.0.0/16"]
}

# Subnet 1: Service Endpoint Etkinleştirilmiş Alt Ağ
resource "azurerm_subnet" "service_endpoint_subnet" {
  name                 = "snet-service-endpoints"
  resource_group_name  = azurerm_resource_group.endpoints_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.50.1.0/24"]

  # Microsoft.Storage için Service Endpoint Etkinleştiriliyor
  service_endpoints = ["Microsoft.Storage"]
}

# Subnet 2: Private Endpoint İçin Özel Alt Ağ
resource "azurerm_subnet" "private_endpoint_subnet" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.endpoints_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.50.2.0/24"]
}

# 3. Azure Storage Account (PaaS Kaynağı)
resource "azurerm_storage_account" "secure_storage" {
  name                     = "staz104mod06sec2026"
  resource_group_name      = azurerm_resource_group.endpoints_rg.name
  location                 = azurerm_resource_group.endpoints_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Güvenlik Duvarı Yapılandırması (Service Endpoint Kuralı)
  network_rules {
    default_action             = "Deny" # Varsayılan olarak tüm internete kapat
    virtual_network_subnet_ids = [azurerm_subnet.service_endpoint_subnet.id]
    bypass                     = ["Metrics", "Logging"]
  }
}

# 4. Azure Private Endpoint (Storage Blob İçin Özel Uç Nokta)
resource "azurerm_private_endpoint" "storage_private_endpoint" {
  name                = "pe-storage-blob"
  location            = azurerm_resource_group.endpoints_rg.location
  resource_group_name = azurerm_resource_group.endpoints_rg.name
  subnet_id           = azurerm_subnet.private_endpoint_subnet.id

  private_service_connection {
    name                           = "psc-storage-blob"
    private_connection_resource_id = azurerm_storage_account.secure_storage.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}

# Outputs
output "storage_account_id" {
  value = azurerm_storage_account.secure_storage.id
}

output "private_endpoint_ip" {
  value       = azurerm_private_endpoint.storage_private_endpoint.private_service_connection[0].private_ip_address
  description = "Storage Account için atanan VNet İçi Özel IP Adresi (Private Link)"
}