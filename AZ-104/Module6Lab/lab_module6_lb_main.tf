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
resource "azurerm_resource_group" "lb_rg" {
  name     = "rg-az104-module6-loadbalancer"
  location = "westeurope"

  tags = {
    Environment = "Production"
    Module      = "AZ104-Module06-LoadBalancer"
    ManagedBy   = "Terraform"
  }
}

# 2. Public IP Address (Standard SKU Load Balancer İçin Standard ZORUNLUDUR)
resource "azurerm_public_ip" "lb_pip" {
  name                = "pip-lb-prod-westeurope"
  location            = azurerm_resource_group.lb_rg.location
  resource_group_name = azurerm_resource_group.lb_rg.name
  allocation_method   = "Static"
  sku                 = "Standard" # Standard SKU Load Balancer için Standard olmalıdır
}

# 3. Azure Standard Public Load Balancer
resource "azurerm_lb" "public_lb" {
  name                = "lbi-web-prod-01"
  location            = azurerm_resource_group.lb_rg.location
  resource_group_name = azurerm_resource_group.lb_rg.name
  sku                 = "Standard" # Üretim ortamları için Standard SKU önerilir

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }
}

# 4. Backend Address Pool (Arka Uç Sunucu Havuzu)
resource "azurerm_lb_backend_address_pool" "backend_pool" {
  loadbalancer_id = azurerm_lb.public_lb.id
  name            = "snet-web-backend-pool"
}

# 5. Health Probe (HTTP 80 Portu Durum Yoklaması)
resource "azurerm_lb_probe" "hp_http_80" {
  loadbalancer_id     = azurerm_lb.public_lb.id
  name                = "hp-http-port80"
  protocol            = "Http"
  port                = 80
  request_path        = "/"
  interval_in_seconds = 15
  number_of_probes    = 2 # Unhealthy threshold (Üst üste 2 başarısız yoklama sunucuyu çıkarır)
}

# 6. Load Balancing Rule (Yük Dengeleme Kuralı - Port 80)
resource "azurerm_lb_rule" "lbr_http_80" {
  loadbalancer_id                = azurerm_lb.public_lb.id
  name                           = "lbr-http-80-to-80"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pool.id]
  probe_id                       = azurerm_lb_probe.hp_http_80.id
  
  # Session Persistence Ayarı: Default 'SourceIP' veya 'None' yapılabilir
  load_distribution              = "Default" # 'None', 'SourceIP', 'SourceIPProtocol'
  idle_timeout_in_minutes        = 4
}

# Outputs
output "load_balancer_public_ip" {
  value       = azurerm_public_ip.lb_pip.ip_address
  description = "Web uygulamasının dış dünyaya açılan Public IP Adresi"
}

output "load_balancer_id" {
  value = azurerm_lb.public_lb.id
}