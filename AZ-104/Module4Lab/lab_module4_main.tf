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
resource "azurerm_resource_group" "network_rg" {
  name     = "rg-az104-module4-networking"
  location = "westeurope"

  tags = {
    Environment = "Production"
    Module      = "AZ104-Module04"
    ManagedBy   = "Terraform"
  }
}

# 2. Virtual Network (VNet)
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-az104-corp-weu"
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
  address_space       = ["10.10.0.0/16"]

  tags = {
    CostCenter = "IT-Networking"
  }
}

# 3. Web Subnet
resource "azurerm_subnet" "web_subnet" {
  name                 = "snet-web-01"
  resource_group_name  = azurerm_resource_group.network_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

# 4. VPN Gateway Subnet (Zorunlu İsimlendirme: GatewaySubnet)
resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.network_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.255.0/27"]
}

# 5. Network Security Group (NSG)
resource "azurerm_network_security_group" "web_nsg" {
  name                = "nsg-web-01"
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name

  security_rule {
    name                       = "AllowHTTPSInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# 6. NSG ve Subnet İlişkilendirmesi
resource "azurerm_subnet_network_security_group_association" "web_nsg_assoc" {
  subnet_id                 = azurerm_subnet.web_subnet.id
  network_security_group_id = azurerm_network_security_group.web_nsg.id
}

# 7. Standard SKU Static Public IP Adresi
resource "azurerm_public_ip" "web_pip" {
  name                = "pip-web-server-01"
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Usage = "WebServerPublicIP"
  }
}

# 8. Network Interface (NIC) - Statik Private IP ve Public IP Bağlantısı
resource "azurerm_network_interface" "web_nic" {
  name                = "nic-web-server-01"
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.web_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.10.1.10" # İlk 5 IP Azure tarafından ayrıldığı için .10 seçildi
    public_ip_address_id          = azurerm_public_ip.web_pip.id
  }
}

# Çıktılar (Outputs)
output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "assigned_public_ip" {
  value = azurerm_public_ip.web_pip.ip_address
}

output "assigned_private_ip" {
  value = azurerm_network_interface.web_nic.ip_configuration[0].private_ip_address
}