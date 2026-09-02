#Aşağıdaki HCL kodu, **Standard (S1)** katmanında bir Linux App Service Planı, buna bağlı bir Web App ve CPU kullanımına göre otomatik ölçeklendirme (Autoscale) kuralını tanımlar:

# Kaynak Grubu

resource "azurerm_resource_group" "rg" {
  name     = "rg-paas-prod"
  location = "westeurope"
}

# App Service Plan (Standard S1 Katmanı - Production)
resource "azurerm_service_plan" "app_plan" {
  name                = "asp-web-prod-we"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "S1"
}

# Linux Web App
resource "azurerm_linux_web_app" "web_app" {
  name                = "app-hotel-booking-prod-001"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.app_plan.id

  site_config {
    always_on = true
    application_stack {
      node_version = "18-lts"
    }
  }
}

# App Service Plan Otomatik Ölçeklendirme Kuralı
resource "azurerm_monitor_autoscale_setting" "app_autoscale" {
  name                = "autoscale-asp-hotel"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  target_resource_id  = azurerm_service_plan.app_plan.id

  profile {
    name = "DefaultProfile"

    capacity {
      default = 2
      minimum = 2
      maximum = 10
    }

    # Scale-Out Rule: CPU > %70 ise 1 örnek artır
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.app_plan.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    # Scale-In Rule: CPU < %30 ise 1 örnek azalt
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.app_plan.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }
}