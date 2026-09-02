#Aşağıdaki HCL kodu, Staging yuvasına (Deployment Slot) sahip bir Linux Web App, HTTPS zorunluluğu, Özel Tanılama Ayarları ve Application Insights entegrasyonunu dağıtmaktadır:

# Kaynak Grubu
resource "azurerm_resource_group" "rg" {
  name     = "rg-app-prod"
  location = "westeurope"
}

# App Service Plan (Standard S1)
resource "azurerm_service_plan" "asp" {
  name                = "asp-prod-westeurope"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "S1"
}

# Application Insights
resource "azurerm_application_insights" "appinsights" {
  name                = "appinsights-prod"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

# Main Web App (Production Slot)
resource "azurerm_linux_web_app" "webapp" {
  name                = "app-mycompany-prod-001"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.asp.id
  https_only          = true

  site_config {
    always_on = true
    application_stack {
      dotnet_version = "7.0"
    }
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"                  = azurerm_application_insights.appinsights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"         = azurerm_application_insights.appinsights.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
  }
}

# Staging Deployment Slot
resource "azurerm_linux_web_app_slot" "staging_slot" {
  name           = "staging"
  app_service_id = azurerm_linux_web_app.webapp.id

  site_config {
    always_on = true
    application_stack {
      dotnet_version = "7.0"
    }
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"          = azurerm_application_insights.appinsights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.appinsights.connection_string
  }
}