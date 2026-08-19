#Custom RBAC Role & Role Assignment Scoping
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.70.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.40.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {}
data "azuread_domains" "default" { only_initial = true }

# 1. Hedef Kaynak Grubu
resource "azurerm_resource_group" "rbac_rg" {
  name     = "rg-az104-lab3-rbac"
  location = "westeurope"
}

# 2. Özel RBAC Rol Tanımı (Custom Role)
resource "azurerm_role_definition" "custom_vm_operator" {
  name        = "AZ104 Custom VM Restart Administrator"
  scope       = data.azurerm_subscription.current.id
  description = "Sadece VM okuma ve yeniden baslatma yetkisi verir."

  permissions {
    actions = [
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Compute/virtualMachines/read",
      "Microsoft.Compute/virtualMachines/restart/action"
    ]
    not_actions = []
  }

  assignable_scopes = [data.azurerm_subscription.current.id]
}

# 3. Test Kullanıcısı Oluşturma
resource "azuread_user" "operator_user" {
  user_principal_name   = "az104-vm-operator@${data.azuread_domains.default.domains[0].domain_name}"
  display_name          = "AZ104 VM Operator User"
  mail_nickname         = "az104-vm-operator"
  password              = "P@ssw0rd123456!"
  force_password_change = true
}

# 4. Rolü Kaynak Grubu Kapsamında Kullanıcıya Atama (Role Assignment)
resource "azurerm_role_assignment" "assign_custom_role" {
  scope                = azurerm_resource_group.rbac_rg.id
  role_definition_id   = azurerm_role_definition.custom_vm_operator.role_definition_resource_id
  principal_id         = azuread_user.operator_user.object_id
}