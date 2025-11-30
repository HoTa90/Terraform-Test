terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.54.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}


provider "random" {
  # Configuration options
}

provider "azurerm" {
  # Configuration options
  features {

  }
  subscription_id = "e9740d7a-e712-4193-92c1-7b77407e7b7d"

}

resource "random_integer" "randomInt" {
  min = 1
  max = 50000
}


resource "azurerm_resource_group" "azg" {
  name     = "${var.resource_group_name}${random_integer.randomInt.result}"
  location = var.resource_group_location
}

resource "azurerm_service_plan" "asp" {
  name                = "${var.app_service_plan_name}${random_integer.randomInt.result}"
  resource_group_name = azurerm_resource_group.azg.name
  location            = azurerm_resource_group.azg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "alwa" {
  name                = "${var.app_service_name}${random_integer.randomInt.result}"
  resource_group_name = azurerm_resource_group.azg.name
  location            = azurerm_service_plan.asp.location
  service_plan_id     = azurerm_service_plan.asp.id

  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.ams.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.amsd.name};User ID=${azurerm_mssql_server.ams.administrator_login};Password=${azurerm_mssql_server.ams.administrator_login_password};Trusted_Connection=False; MultipleActiveResultSets=True;"
  }

  site_config {
    application_stack {
      dotnet_version = "6.0"

    }
    always_on = false
  }
}

resource "azurerm_mssql_server" "ams" {
  name                         = "${var.sql_server_name}${random_integer.randomInt.result}"
  resource_group_name          = azurerm_resource_group.azg.name
  location                     = azurerm_resource_group.azg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login_username
  administrator_login_password = var.sql_admin_login_password
}

resource "azurerm_mssql_database" "amsd" {
  name                 = "${var.sql_database_name}${random_integer.randomInt.result}"
  server_id            = azurerm_mssql_server.ams.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  license_type         = "LicenseIncluded"
  max_size_gb          = 2
  sku_name             = "S0"
  enclave_type         = "VBS"
  storage_account_type = "Local"
}

resource "azurerm_mssql_firewall_rule" "amfr" {
  name             = var.firewall_rule_name
  server_id        = azurerm_mssql_server.ams.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_app_service_source_control" "example" {
  app_id                 = azurerm_linux_web_app.alwa.id
  repo_url               = var.github_repo_url
  branch                 = "main"
  use_manual_integration = true
}