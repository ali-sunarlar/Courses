# Aşağıdaki Terraform kodu; **Hub VNet** ve **Spoke VNet** mimarisini kurar, aralarında çift yönlü **VNet Peering** ilişkisi tanımlar ve eşleme parametrelerini (Gateway Transit, Allow Forwarded Traffic vb.) eksiksiz yapılandırır.
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
resource "azurerm_resource_group" "peering_rg" {
  name     = "rg-az104-module5-peering"
  location = "westeurope"

  tags = {
    Environment = "Production"
    Module      = "AZ104-Module05-VNetPeering"
    ManagedBy   = "Terraform"
  }
}

# 2. Hub Virtual Network (Merkez Ağ)
resource "azurerm_virtual_network" "hub_vnet" {
  name                = "vnet-hub-westeurope"
  location            = azurerm_resource_group.peering_rg.location
  resource_group_name = azurerm_resource_group.peering_rg.name
  address_space       = ["10.100.0.0/16"]
}

resource "azurerm_subnet" "hub_default_subnet" {
  name                 = "snet-hub-core"
  resource_group_name  = azurerm_resource_group.peering_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = ["10.100.1.0/24"]
}

# 3. Spoke Virtual Network (Açılan İş Yükü Ağı)
resource "azurerm_virtual_network" "spoke_vnet" {
  name                = "vnet-spoke-workloads"
  location            = azurerm_resource_group.peering_rg.location
  resource_group_name = azurerm_resource_group.peering_rg.name
  address_space       = ["10.200.0.0/16"]
}

resource "azurerm_subnet" "spoke_app_subnet" {
  name                 = "snet-spoke-apps"
  resource_group_name  = azurerm_resource_group.peering_rg.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = ["10.200.1.0/24"]
}

# 4. VNet Peering: Hub -> Spoke Eşlemesi
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "peer-hub-to-spoke"
  resource_group_name          = azurerm_resource_group.peering_rg.name
  virtual_network_name         = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false # Hub üzerinde bir Gateway kurulduğunda 'true' yapılır
  use_remote_gateways          = false
}

# 5. VNet Peering: Spoke -> Hub Eşlemesi
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "peer-spoke-to-hub"
  resource_group_name          = azurerm_resource_group.peering_rg.name
  virtual_network_name         = azurerm_virtual_network.spoke_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.hub_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false # Hub üzerindeki Gateway'i kullanmak için 'true' yapılır
}

# Outputs
output "hub_vnet_id" {
  value = azurerm_virtual_network.hub_vnet.id
}

output "spoke_vnet_id" {
  value = azurerm_virtual_network.spoke_vnet.id
}

output "peering_hub_to_spoke_status" {
  value = azurerm_virtual_network_peering.hub_to_spoke.id
}