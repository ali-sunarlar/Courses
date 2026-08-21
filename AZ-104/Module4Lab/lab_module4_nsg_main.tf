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
resource "azurerm_resource_group" "nsg_rg" {
  name     = "rg-az104-module4-nsg"
  location = "westeurope"

  tags = {
    Environment = "Production"
    Module      = "AZ104-Module04-NSG"
  }
}

# 2. Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-erp-production"
  location            = azurerm_resource_group.nsg_rg.location
  resource_group_name = azurerm_resource_group.nsg_rg.name
  address_space       = ["10.20.0.0/16"]
}

# 3. Web & App Subnet'leri
resource "azurerm_subnet" "web_subnet" {
  name                 = "snet-web-tier"
  resource_group_name  = azurerm_resource_group.nsg_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.20.1.0/24"]
}

resource "azurerm_subnet" "app_subnet" {
  name                 = "snet-app-tier"
  resource_group_name  = azurerm_resource_group.nsg_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.20.2.0/24"]
}

# 4. Web Tier Subnet NSG (HTTPS İzni)
resource "azurerm_network_security_group" "web_nsg" {
  name                = "nsg-web-subnet"
  location            = azurerm_resource_group.nsg_rg.location
  resource_group_name = azurerm_resource_group.nsg_rg.name

  security_rule {
    name                       = "AllowHTTPSInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPInbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

# 5. Subnet ve NSG Bağlantısı
resource "azurerm_subnet_network_security_group_association" "web_assoc" {
  subnet_id                 = azurerm_subnet.web_subnet.id
  network_security_group_id = azurerm_network_security_group.web_nsg.id
}

# 6. Sanal Makine NIC ve NIC Seviyesinde NSG
resource "azurerm_network_interface" "app_nic" {
  name                = "nic-erp-app-01"
  location            = azurerm_resource_group.nsg_rg.location
  resource_group_name = azurerm_resource_group.nsg_rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.app_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "app_nic_nsg" {
  name                = "nsg-app-nic-01"
  location            = azurerm_resource_group.nsg_rg.location
  resource_group_name = azurerm_resource_group.nsg_rg.name

  # Sadece Web Subnet'ten gelen trafiğe izin ver (Least Privilege)
  security_rule {
    name                       = "AllowWebSubnetToApp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "10.20.1.0/24"
    destination_address_prefix = "*"
  }
}

# 7. NIC ve NSG Bağlantısı
resource "azurerm_network_interface_security_group_association" "nic_assoc" {
  network_interface_id      = azurerm_network_interface.app_nic.id
  network_security_group_id = azurerm_network_security_group.app_nic_nsg.id
}

output "web_subnet_nsg_id" {
  value = azurerm_network_security_group.web_nsg.id
}

output "app_nic_nsg_id" {
  value = azurerm_network_security_group.app_nic_nsg.id
}