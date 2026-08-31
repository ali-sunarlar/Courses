#Aşağıdaki HCL kodu, bir Sanal Ağ, Alt Ağ, Ağ Arabirimi (NIC) ve Linux Sanal Makinesi (Ubuntu) ile ona bağlı bir Veri Diski (Data Disk) dağıtımını gerçekleştirir:
# Kaynak Grubu
resource "azurerm_resource_group" "rg" {
  name     = "rg-compute-prod"
  location = "westeurope"
}

# Sanal Ağ ve Alt Ağ
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-prod-westeurope"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "snet-web-prod"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Ağ Arabirimi (NIC)
resource "azurerm_network_interface" "nic" {
  name                = "nic-prodwe-webvm01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Linux Sanal Makine (D2s_v5 Genel Amaçlı)
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "prodwe-webvm01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2s_v5"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# Yönetilen Veri Diski (Managed Data Disk)
resource "azurerm_managed_disk" "data_disk" {
  name                 = "disk-prodwe-webvm01-data01"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 1024 # 1 TB Veri Diski
}

# Veri Diskini Sanal Makineye Bağlama (Attach)
resource "azurerm_virtual_machine_data_disk_attachment" "disk_attach" {
  managed_disk_id    = azurerm_managed_disk.data_disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm.id
  lun                = "0"
  caching            = "ReadWrite"
}