#Aşağıdaki HCL kodu, Azure Container Instances (ACI) üzerinde 80 portunu dışarıya açan, Azure Files birim bağlamasına (volume mount) sahip bir Linux Konteyner Grubu tanımlamaktadır:

# Kaynak Grubu
resource "azurerm_resource_group" "rg" {
  name     = "rg-aci-prod"
  location = "westeurope"
}

# Kalıcı Depolama için Storage Account ve File Share
resource "azurerm_storage_account" "sa" {
  name                     = "stacidata2026we"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "share" {
  name                 = "aci-share"
  storage_account_name = azurerm_storage_account.sa.name
  quota                = 10
}

# Azure Container Group (ACI) Dağıtımı
resource "azurerm_container_group" "aci_group" {
  name                = "aci-web-app-group"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_address_type     = "Public"
  dns_name_label      = "mycompany-app-2026"
  os_type             = "Linux"

  # Konteyner 1: Web Sunucusu (Nginx)
  container {
    name   = "web-server"
    image  = "[mcr.microsoft.com/azuredocs/aci-helloworld:latest](https://mcr.microsoft.com/azuredocs/aci-helloworld:latest)"
    cpu    = "1.0"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }

    # Azure File Share Bağlama (Volume Mount)
    volume {
      name                 = "data-volume"
      mount_path           = "/aci/data"
      storage_account_name = azurerm_storage_account.sa.name
      storage_account_key  = azurerm_storage_account.sa.primary_access_key
      share_name           = azurerm_storage_share.share.name
    }
  }

  tags = {
    environment = "production"
  }
}