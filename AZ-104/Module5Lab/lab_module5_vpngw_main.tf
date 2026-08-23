#Aşağıdaki Terraform kodu; **`GatewaySubnet`** içeren bir Sanal Ağ, Azure **VPN Gateway (VpnGw1)**, Şirket içi ağı temsil eden **Local Network Gateway** ve aralarındaki **S2S IPsec VPN Bağlantısını** tam parametreleriyle dağıtır.
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
resource "azurerm_resource_group" "vpngw_rg" {
  name     = "rg-az104-module5-vpngw"
  location = "westeurope"

  tags = {
    Environment = "Production"
    Module      = "AZ104-Module05-VPNGateway"
    ManagedBy   = "Terraform"
  }
}

# 2. Virtual Network & Subnets
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-site-westeurope"
  location            = azurerm_resource_group.vpngw_rg.location
  resource_group_name = azurerm_resource_group.vpngw_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "workload_subnet" {
  name                 = "snet-workloads"
  resource_group_name  = azurerm_resource_group.vpngw_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Gateway Subnet ZORUNLU İSİMDİR (GatewaySubnet)
resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.vpngw_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.255.0/27"] # /27 veya /28 önerilir
}

# 3. Public IP for Azure VPN Gateway
resource "azurerm_public_ip" "vpngw_pip" {
  name                = "pip-vpngw-westeurope"
  location            = azurerm_resource_group.vpngw_rg.location
  resource_group_name = azurerm_resource_group.vpngw_rg.name
  allocation_method   = "Dynamic" # VpnGw1 Generation1 için Dynamic/Static desteklenir
  sku                 = "Basic"
}

# 4. Azure Virtual Network Gateway (VPN Gateway)
resource "azurerm_virtual_network_gateway" "vpngw" {
  name                = "vpngw-westeurope-01"
  location            = azurerm_resource_group.vpngw_rg.location
  resource_group_name = azurerm_resource_group.vpngw_rg.name

  type     = "Vpn"
  vpn_type = "RouteBased" # S2S, P2S ve VNet-to-VNet için varsayılan

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"
  generation    = "Generation1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpngw_pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway_subnet.id
  }
}

# 5. Local Network Gateway (Şirket İçi Veri Merkezini Temsil Eder)
resource "azurerm_local_network_gateway" "onprem_local_gw" {
  name                = "lng-onprem-datacenter"
  location            = azurerm_resource_group.vpngw_rg.location
  resource_group_name = azurerm_resource_group.vpngw_rg.name
  gateway_address     = "203.0.113.10" # Şirket içi VPN Cihazının Dış IP Adresi

  address_space = [
    "192.168.1.0/24",
    "192.168.2.0/24"
  ] # Şirket içindeki subnet blokları
}

# 6. Site-to-Site VPN Connection
resource "azurerm_virtual_network_gateway_connection" "s2s_connection" {
  name                       = "conn-s2s-azure-to-onprem"
  location                   = azurerm_resource_group.vpngw_rg.location
  resource_group_name        = azurerm_resource_group.vpngw_rg.name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpngw.id
  local_network_gateway_id   = azurerm_local_network_gateway.onprem_local_gw.id

  shared_key = "P@ssw0rdAzureS2SKey2026!" # Şirket içi cihazla eşleşmesi gereken PSK
}

# Outputs
output "vpn_gateway_public_ip" {
  value       = azurerm_public_ip.vpngw_pip.ip_address
  description = "Şirket içi VPN cihazına tanımlanacak Azure VPN Gateway Public IP adresi"
}

output "vpn_connection_id" {
  value = azurerm_virtual_network_gateway_connection.s2s_connection.id
}