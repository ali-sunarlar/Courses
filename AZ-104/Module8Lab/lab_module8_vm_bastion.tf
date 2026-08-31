#Sanal makinelerinizi dış dünyaya (Public IP) açmadan güvenli erişim sağlamak için Azure Bastion altyapısını kod olarak aşağıdaki şekilde dağıtabilirsiniz:
# Bastion için Özel Alt Ağ (Adı mutlaka AzureBastionSubnet olmalıdır)
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = "rg-compute-prod"
  virtual_network_name = "vnet-prod-westeurope"
  address_prefixes     = ["10.0.2.0/26"] # Minimum /26 blok gereklidir
}

# Bastion için Public IP (Standard SKU şarttır)
resource "azurerm_public_ip" "bastion_pip" {
  name                = "pip-bastion-prod"
  location            = "westeurope"
  resource_group_name = "rg-compute-prod"
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Azure Bastion Host Kaynağı
resource "azurerm_bastion_host" "bastion" {
  name                = "bastion-prod-westeurope"
  location            = "westeurope"
  resource_group_name = "rg-compute-prod"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }