#Cloud Shell depolama alanı, Resource Group, Resource Lock (Delete Lock) ve ARM Template Dağıtımı
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.70.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# 1. Benzersiz İsim Üreteci
resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

# 2. Ana Kaynak Grubu
resource "azurerm_resource_group" "m3_rg" {
  name     = "rg-az104-module3-advanced"
  location = "westeurope"

  tags = {
    Environment = "Training"
    ManagedBy   = "Terraform"
  }
}

# 3. Kaynak Kilidi (Delete Lock)
resource "azurerm_management_lock" "m3_lock" {
  name       = "lock-prevent-rg-delete"
  scope      = azurerm_resource_group.m3_rg.id
  lock_level = "CanNotDelete"
  notes      = "Module 3 - Kazara silinmeyi onleme kilidi."
}

# 4. Cloud Shell Depolama Hesabı ve File Share
resource "azurerm_storage_account" "clshell_sa" {
  name                     = "stclshell${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.m3_rg.name
  location                 = azurerm_resource_group.m3_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "clshell_share" {
  name                 = "cloudshell-share"
  storage_account_name = azurerm_storage_account.clshell_sa.name
  quota                = 5
}

# 5. ARM Template Üzerinden Kaynak Dağıtımı (ARM Integration in Terraform)
resource "azurerm_resource_group_template_deployment" "arm_example" {
  name                = "arm-deploy-storage-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.m3_rg.name
  deployment_mode     = "Incremental"

  template_content = jsonencode({
    "$schema"        = "[https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#](https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#)"
    "contentVersion" = "1.0.0.0"
    "parameters"     = {
      "storageAccountName" = {
        "type"         = "string"
        "defaultValue" = "starm${random_string.suffix.result}"
      }
    }
    "resources" = [
      {
        "type"       = "Microsoft.Storage/storageAccounts"
        "apiVersion" = "2021-09-01"
        "name"       = "[parameters('storageAccountName')]"
        "location"   = azurerm_resource_group.m3_rg.location
        "sku"        = { "name" = "Standard_LRS" }
        "kind"       = "StorageV2"
      }
    ]
  })
}

output "resource_group_name" {
  value = azurerm_resource_group.m3_rg.name
}

output "arm_deployed_storage_name" {
  value = "starm${random_string.suffix.result}"
}