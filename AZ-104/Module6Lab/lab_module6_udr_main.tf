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
resource "azurerm_resource_group" "udr_rg" {
  name     = "rg-az104-module6-udr"
  location = "westeurope"

  tags = {
    Environment = "Production"
    Module      = "AZ104-Module06-UDR"
    ManagedBy   = "Terraform"
  }
}

# 2. Virtual Network & Subnets (Public, DMZ, Private)
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-routing-westeurope"
  location            = azurerm_resource_group.udr_rg.location
  resource_group_name = azurerm_resource_group.udr_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "public_subnet" {
  name                 = "snet-public"
  resource_group_name  = azurerm_resource_group.udr_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "private_subnet" {
  name                 = "snet-private"
  resource_group_name  = azurerm_resource_group.udr_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "dmz_subnet" {
  name                 = "snet-dmz"
  resource_group_name  = azurerm_resource_group.udr_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# 3. NVA (Ağ Sanal Cihazı) İçin Ağ Arabirimi - IP Forwarding Etkin!
resource "azurerm_network_interface" "nva_nic" {
  name                 = "nic-nva-firewall-01"
  location             = azurerm_resource_group.udr_rg.location
  resource_group_name  = azurerm_resource_group.udr_rg.name
  enable_ip_forwarding = true # NVA için KRİTİK AYAR! (Trafiği iletmesine izin verir)

  ip_configuration {
    name                          = "ipconfig-nva"
    subnet_id                     = azurerm_subnet.dmz_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.4" # Sabit NVA IP Adresi
  }
}

# 4. Route Table (Kullanıcı Tanımlı Rota Tablosu - UDR)
resource "azurerm_route_table" "public_udr_table" {
  name                          = "rt-public-to-nva"
  location                      = azurerm_resource_group.udr_rg.location
  resource_group_name           = azurerm_resource_group.udr_rg.name
  disable_bgp_route_propagation = false

  # Özel Rota Tanımı: Private Subnet'e giden trafik NVA'ya (10.0.2.4) yönlendirilir
  route {
    name                   = "ToPrivateSubnetViaNVA"
    address_prefix         = "10.0.1.0/24" # Private Subnet Adres Bloğu
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.2.4" # NVA IP Adresi
  }

  tags = {
    RoutingPolicy = "ForcedThroughNVA"
  }
}

# 5. Route Table'ı Public Subnet ile İlişkilendirme (Association)
resource "azurerm_subnet_route_table_association" "public_subnet_assoc" {
  subnet_id      = azurerm_subnet.public_subnet.id
  route_table_id = azurerm_route_table.public_udr_table.id
}

# Outputs
output "nva_private_ip" {
  value       = azurerm_network_interface.nva_nic.private_ip_address
  description = "Ağ Sanal Cihazının (NVA) Statik Özel IP Adresi"
}

output "route_table_id" {
  value       = azurerm_route_table.public_udr_table.id
  description = "Public Subnet'e bağlanan Rota Tablosunun ID'si"
}