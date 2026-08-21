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
resource "azurerm_resource_group" "fw_rg" {
  name     = "rg-az104-module4-firewall"
  location = "westeurope"

  tags = {
    Environment = "Production"
    Module      = "AZ104-Module04-Firewall"
    ManagedBy   = "Terraform"
  }
}

# 2. Hub VNet (Merkez Ağ)
resource "azurerm_virtual_network" "hub_vnet" {
  name                = "vnet-hub-weu-01"
  location            = azurerm_resource_group.fw_rg.location
  resource_group_name = azurerm_resource_group.fw_rg.name
  address_space       = ["10.100.0.0/16"]
}

# 3. Azure Firewall Subnet (İsim Zorunluluğu: AzureFirewallSubnet & min /26 prefix)
resource "azurerm_subnet" "fw_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.fw_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = ["10.100.1.0/26"]
}

# 4. Spoke VNet (İş Yükü Ağı)
resource "azurerm_virtual_network" "spoke_vnet" {
  name                = "vnet-spoke-workloads-01"
  location            = azurerm_resource_group.fw_rg.location
  resource_group_name = azurerm_resource_group.fw_rg.name
  address_space       = ["10.200.0.0/16"]
}

resource "azurerm_subnet" "workload_subnet" {
  name                 = "snet-workload-01"
  resource_group_name  = azurerm_resource_group.fw_rg.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = ["10.200.1.0/24"]
}

# 5. Hub - Spoke Peering
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "peer-hub-to-spoke"
  resource_group_name       = azurerm_resource_group.fw_rg.name
  virtual_network_name      = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.spoke_vnet.id
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "peer-spoke-to-hub"
  resource_group_name       = azurerm_resource_group.fw_rg.name
  virtual_network_name      = azurerm_virtual_network.spoke_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id
}

# 6. Azure Firewall Public IP (Standard SKU & Static)
resource "azurerm_public_ip" "fw_pip" {
  name                = "pip-azfw-weu-01"
  location            = azurerm_resource_group.fw_rg.location
  resource_group_name = azurerm_resource_group.fw_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 7. Azure Firewall Örneği (AZ Firewall Standard)
resource "azurerm_firewall" "az_fw" {
  name                = "fw-corp-central-01"
  location            = azurerm_resource_group.fw_rg.location
  resource_group_name = azurerm_resource_group.fw_rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = azurerm_subnet.fw_subnet.id
    public_ip_address_id = azurerm_public_ip.fw_pip.id
  }
}

# 8. Firewall Network Rule Collection (IP/Port Tabanlı İzinler)
resource "azurerm_firewall_network_rule_collection" "net_rules" {
  name                = "net-rule-collection-01"
  azure_firewall_name = azurerm_firewall.az_fw.name
  resource_group_name = azurerm_resource_group.fw_rg.name
  priority            = 100
  action              = "Allow"

  rule {
    name                  = "AllowDNSOutbound"
    source_addresses      = ["10.200.1.0/24"]
    destination_ports     = ["53"]
    destination_addresses = ["8.8.8.8", "1.1.1.1"]
    protocols             = ["UDP", "TCP"]
  }
}

# 9. Firewall Application Rule Collection (FQDN Tabanlı İzinler)
resource "azurerm_firewall_application_rule_collection" "app_rules" {
  name                = "app-rule-collection-01"
  azure_firewall_name = azurerm_firewall.az_fw.name
  resource_group_name = azurerm_resource_group.fw_rg.name
  priority            = 200
  action              = "Allow"

  rule {
    name             = "AllowWindowsUpdateAndUbuntu"
    source_addresses = ["10.200.1.0/24"]
    target_fqdns     = ["*.microsoft.com", "canonical.com", "ubuntu.com"]

    protocol {
      port = "443"
      type = "Https"
    }
  }
}

# Outputs
output "firewall_private_ip" {
  value       = azurerm_firewall.az_fw.ip_configuration[0].private_ip_address
  description = "Spoke ağlarından trafiği yönlendirmek için Route Table (UDR)'da kullanılacak Firewall Private IP Adresi"
}

output "firewall_public_ip" {
  value       = azurerm_public_ip.fw_pip.ip_address
  description = "Dış dünyadan gelen istekler (DNAT) için kullanılacak Public IP"
}