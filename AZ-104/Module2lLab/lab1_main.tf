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

# 1. Management Group Hiyerarşisi
resource "azurerm_management_group" "corp_root" {
  name         = "mg-contoso-corp"
  display_name = "Contoso Corporate Root MG"
}

resource "azurerm_management_group" "corp_landingzones" {
  name                       = "mg-contoso-landingzones"
  display_name               = "Contoso Landing Zones"
  parent_management_group_id = azurerm_management_group.corp_root.id
}

# 2. Policy Initiative (İnisiyatif) Oluşturma
resource "azurerm_policy_set_definition" "governance_initiative" {
  name         = "initiative-governance-baseline"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Contoso Governance Baseline Initiative"

  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e562320d-329c-4e0b-9323-ed30f27a9729" # Allowed Locations
    parameter_values     = jsonencode({
      listOfAllowedLocations = { value = ["westeurope", "northeurope"] }
    })
  }

  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10a5-4acc-853f-36f1c2e9e057" # Require Tag
    parameter_values     = jsonencode({
      tagName = { value = "Environment" }
    })
  }
}

# 3. İnisiyatifi Yönetim Grubuna Atama
resource "azurerm_management_group_policy_assignment" "assign_initiative" {
  name                 = "assign-gov-baseline"
  management_group_id  = azurerm_management_group.corp_landingzones.id
  policy_definition_id = azurerm_policy_set_definition.governance_initiative.id
}