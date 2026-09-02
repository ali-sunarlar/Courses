#Aşağıdaki HCL kodu, Otomatik Ölçeklendirme (Cluster Autoscaler) etkinleştirilmiş bir AKS kümesini ve ona bağlı bir Düğüm Havuzunu (Node Pool) dağıtmaktadır:
# Kaynak Grubu
resource "azurerm_resource_group" "rg" {
  name     = "rg-aks-prod"
  location = "westeurope"
}

# AKS Kümesi (Managed Kubernetes)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-fleet-prod-001"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aksfleetprod"

  # System Node Pool (Cluster Autoscaler Etkin)
  default_node_pool {
    name                = "systempool"
    vm_size             = "Standard_D2s_v5"
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 5
    os_disk_size_gb     = 50
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }

  tags = {
    environment = "production"
  }
}

# Ek User Node Pool (Uygulama İş Yükleri İçin)
resource "azurerm_kubernetes_cluster_node_pool" "user_pool" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_D4s_v5"
  enable_auto_scaling   = true
  min_count             = 1
  max_count             = 10

  tags = {
    environment = "production"
  }
}