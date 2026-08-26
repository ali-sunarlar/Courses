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
resource "azurerm_resource_group" "appgw_rg" {
  name     = "rg-az104-module6-appgateway"
  location = "westeurope"

  tags = {
    Environment = "Production"
    Module      = "AZ104-Module06-AppGateway"
    ManagedBy   = "Terraform"
  }
}

# 2. Virtual Network ve Subnets
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-appgw-westeurope"
  location            = azurerm_resource_group.appgw_rg.location
  resource_group_name = azurerm_resource_group.appgw_rg.name
  address_space       = ["10.10.0.0/16"]
}

# Application Gateway İçin Ayrılmış Özel Subnet
resource "azurerm_subnet" "appgw_subnet" {
  name                 = "snet-appgateway"
  resource_group_name  = azurerm_resource_group.appgw_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_subnet" "backend_subnet" {
  name                 = "snet-web-backend"
  resource_group_name  = azurerm_resource_group.appgw_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.2.0/24"]
}

# 3. Public IP Address (v2 SKU İçin Static & Standard ZORUNLUDUR)
resource "azurerm_public_ip" "appgw_pip" {
  name                = "pip-appgw-prod-westeurope"
  location            = azurerm_resource_group.appgw_rg.location
  resource_group_name = azurerm_resource_group.appgw_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 4. Azure Application Gateway (WAF_v2 SKU)
resource "azurerm_application_gateway" "network" {
  name                = "appgw-gov-portal-01"
  resource_group_name = azurerm_resource_group.appgw_rg.name
  location            = azurerm_resource_group.appgw_rg.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2 # Autoscaling yapılandırılmazsa sabit kapasite
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.appgw_subnet.id
  }

  frontend_port {
    name = "frontend-port-http"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  # Backend Pool
  backend_address_pool {
    name = "backend-pool-web"
  }

  # Backend HTTP Settings
  backend_http_settings {
    name                  = "http-setting-backend"
    cookie_based_affinity = "Enabled" # Oturum Kalıcılığı (Session Stickiness)
    path                  = ""
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  # Listener (Basic)
  http_listener {
    name                           = "http-listener-basic"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name             = "frontend-port-http"
    protocol                       = "Http"
  }

  # Request Routing Rule
  request_routing_rule {
    name                       = "rule-basic-routing"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener-basic"
    backend_address_pool_name  = "backend-pool-web"
    backend_http_settings_name = "http-setting-backend"
    priority                   = 100
  }

  # Web Application Firewall (WAF) Yapılandırması
  waf_configuration {
    enabled                  = true
    firewall_mode            = "Prevention" # 'Detection' veya 'Prevention'
    rule_set_type            = "OWASP"
    rule_set_version         = "3.0" # OWASP Core Rule Set 3.0
    request_body_check       = true
    max_request_body_size_kb = 128
  }
}

# Outputs
output "application_gateway_public_ip" {
  value       = azurerm_public_ip.appgw_pip.ip_address
  description = "Application Gateway'in dış dünyaya açılan Public IP adresi"
}

output "application_gateway_id" {
  value = azurerm_application_gateway.network.id
}