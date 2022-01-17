provider "azurerm" {
  version = ">=2.0"
  # The "feature" block is required for AzureRM provider 2.x.
  features {}
}
resource "azurerm_resource_group" "RG-Terraform-AZ" {
  name     = "terraform-resource-group-az"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "ASP-TerraForm-AZ" {
  name                = "terraform-appserviceplan-az"
  location            = azurerm_resource_group.RG-Terraform-AZ.location
  resource_group_name = azurerm_resource_group.RG-Terraform-AZ.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "AS-Terraform-AZ" {
  name                = "app-service-terraform-az"
  location            = azurerm_resource_group.RG-Terraform-AZ.location
  resource_group_name = azurerm_resource_group.RG-Terraform-AZ.name
  app_service_plan_id = azurerm_app_service_plan.ASP-TerraForm-AZ.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=tcp:${azurerm_sql_server.test.fully_qualified_domain_name} Database=${azurerm_sql_database.test.name};User ID=${azurerm_sql_server.test.administrator_login};Password=${azurerm_sql_server.test.administrator_login_password};Trusted_Connection=False;Encrypt=True;"
  }
}

resource "azurerm_sql_server" "test" {
  name                         = "terraform-sqlserver-az"
  resource_group_name          = azurerm_resource_group.RG-Terraform-AZ.name
  location                     = azurerm_resource_group.RG-Terraform-AZ.location
  version                      = "12.0"
  administrator_login          = "ilyes.blidaoui"
  administrator_login_password = "Eltaifa1976!"
}

resource "azurerm_sql_database" "test" {
  name                = "terraform-sqldatabase-az"
  resource_group_name = azurerm_resource_group.RG-Terraform-AZ.name
  location            = azurerm_resource_group.RG-Terraform-AZ.location
  server_name         = azurerm_sql_server.test.name

  tags = {
    environment = "production"
  }
}
