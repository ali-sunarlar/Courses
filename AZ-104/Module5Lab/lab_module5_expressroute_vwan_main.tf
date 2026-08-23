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
resource "azurerm_resource_group" "er_vwan_rg" {
  name     = "rg-az104-module5-er-vwan"
  location = "westeurope"

  tags = {
    Environment = "Production"
    Module      = "AZ104-Module05-ER-vWAN"
    ManagedBy   = "Terraform"
  }
}

# 2. Azure ExpressRoute Circuit (Devre Yapılandırması)
resource "azurerm_express_route_circuit" "er_circuit" {
  name                  = "erc-enterprise-westeurope"
  resource_group_name   = azurerm_resource_group.er_vwan_rg.name
  location              = azurerm_resource_group.er_vwan_rg.location
  service_provider_name = "Equinix" # Servis sağlayıcı adı
  peering_location      = "Amsterdam" # ExpressRoute Peering Konumu
  bandwidth_in_mbps     = 50

  sku {
    tier = "Standard" # Premium seçeneği küresel erişim sağlar
    family = "MeteredData" # Sınırsız veri için UnlimitedData
  }

  tags = {
    CostCenter = "IT-Networking"
  }
}

# 3. Azure Virtual WAN
resource "azurerm_virtual_wan" "vwan" {
  name                = "vwan-global-core"
  resource_group_name = azurerm_resource_group.er_vwan_rg.name
  location            = azurerm_resource_group.er_vwan_rg.location
  type                = "Standard" # Standard: S2S, P2S, ExpressRoute ve Inter-hub geçişini destekler

  allow_branch_to_branch_traffic = true
}

# 4. Virtual WAN Hub (Merkez Sanal Hub)
resource "azurerm_virtual_hub" "vwan_hub" {
  name                = "hub-westeurope-01"
  resource_group_name = azurerm_resource_group.er_vwan_rg.name
  location            = azurerm_resource_group.er_vwan_rg.location
  virtual_wan_id      = azurerm_virtual_wan.vwan.id
  address_prefix      = "10.60.0.0/24"
}

# 5. Virtual WAN S2S VPN Gateway (Hub İçi VPN Ağ Geçidi)
resource "azurerm_vpn_gateway" "vwan_s2s_gateway" {
  name                = "vpngw-vwan-hub-01"
  location            = azurerm_resource_group.er_vwan_rg.location
  resource_group_name = azurerm_resource_group.er_vwan_rg.name
  virtual_hub_id      = azurerm_virtual_hub.vwan_hub.id
  scale_unit          = 1
}

# Outputs
output "expressroute_service_key" {
  value       = azurerm_express_route_circuit.er_circuit.service_key
  sensitive   = true
  description = "Ağ servis sağlayıcısına verilecek ExpressRoute Service Key koda duyarlıdır."
}

output "vwan_hub_id" {
  value = azurerm_virtual_hub.vwan_hub.id
}