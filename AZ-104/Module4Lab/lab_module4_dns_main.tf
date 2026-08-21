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
resource "azurerm_resource_group" "dns_rg" {
  name     = "rg-az104-module4-dns"
  location = "westeurope"

  tags = {
    Environment = "Production"
    Module      = "AZ104-Module04-DNS"
    ManagedBy   = "Terraform"
  }
}

# 2. Public DNS Zone (Harici Etki Alanı)
resource "azurerm_dns_zone" "public_zone" {
  name                = "contosogold.com"
  resource_group_name = azurerm_resource_group.dns_rg.name
}

# Public A Kaydı
resource "azurerm_dns_a_record" "web_public_record" {
  name                = "www"
  zone_name           = azurerm_dns_zone.public_zone.name
  resource_group_name = azurerm_resource_group.dns_rg.name
  ttl                 = 3600
  records             = ["20.50.100.1"]
}

# 3. Sanal Ağlar (VNet1: Registration, VNet2: Resolution)
resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet-reg-01"
  location            = azurerm_resource_group.dns_rg.location
  resource_group_name = azurerm_resource_group.dns_rg.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_virtual_network" "vnet2" {
  name                = "vnet-res-01"
  location            = azurerm_resource_group.dns_rg.location
  resource_group_name = azurerm_resource_group.dns_rg.name
  address_space       = ["10.2.0.0/16"]
}

# 4. Private DNS Zone (İç Ağ Etki Alanı)
resource "azurerm_private_dns_zone" "private_zone" {
  name                = "corp.internal"
  resource_group_name = azurerm_resource_group.dns_rg.name
}

# 5. VNet Links (Registration ve Resolution Bağlantıları)
# VNet1: Registration Enable (VM'ler Otomatik Kaydolur)
resource "azurerm_private_dns_zone_virtual_network_link" "vnet1_registration_link" {
  name                  = "link-vnet1-registration"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.private_zone.name
  virtual_network_id    = azurerm_virtual_network.vnet1.id
  registration_enabled  = true
}

# VNet2: Resolution Only (Sadece Çözümleme Yapar, Otomatik Kayıt Yok)
resource "azurerm_private_dns_zone_virtual_network_link" "vnet2_resolution_link" {
  name                  = "link-vnet2-resolution"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.private_zone.name
  virtual_network_id    = azurerm_virtual_network.vnet2.id
  registration_enabled  = false
}

# 6. Manuel Private A Kaydı (Resolution VNet VM'i veya Özel Sunucu İçin)
resource "azurerm_private_dns_a_record" "db_private_record" {
  name                = "db01"
  zone_name           = azurerm_private_dns_zone.private_zone.name
  resource_group_name = azurerm_resource_group.dns_rg.name
  ttl                 = 300
  records             = ["10.2.1.50"]
}

# Outputs
output "public_name_servers" {
  value       = azurerm_dns_zone.public_zone.name_servers
  description = "Domain Registrar paneline girilecek Azure Name Server adresleri"
}

output "private_zone_id" {
  value       = azurerm_private_dns_zone.private_zone.id
  description = "Oluşturulan Private DNS Zone ID'si"
}