#LAB 2: Resource Locks, Tagging & Budget Management
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

# 1. Etiketlenmiş Kaynak Grubu
resource "azurerm_resource_group" "lab_rg" {
  name     = "rg-az104-lab2-governance"
  location = "westeurope"

  tags = {
    Environment = "Production"
    CostCenter  = "IT-Operations"
  }
}

# 2. Kaynak Kilidi (CanNotDelete)
resource "azurerm_management_lock" "rg_lock" {
  name       = "lock-prevent-accidental-delete"
  scope      = azurerm_resource_group.lab_rg.id
  lock_level = "CanNotDelete"
}

# 3. Consumption Budget (Bütçe Uyarısı)
resource "azurerm_consumption_budget_resource_group" "rg_budget" {
  name              = "budget-lab2-monthly"
  resource_group_id = azurerm_resource_group.lab_rg.id

  amount     = 200
  time_grain = "Monthly"

  time_period {
    start_date = "2026-09-01T00:00:00Z"
    end_date   = "2027-09-01T00:00:00Z"
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = ["sysadmin@contoso.com"]
  }
}