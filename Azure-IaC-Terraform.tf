###########################################
# Stock - Terraform #
###########################################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.24.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "#{Project.Azure.RandomQuotes.ResourceGroup.Name}"
    storage_account_name = "#{Project.Azure.RandomQuotes.StorageAccount.Name}"
    container_name       = "#{Project.Azure.RandomQuotes.StorageContainer.Name}"
    key                  = "terraform.tfstate"
  }
}
provider "azurerm" {
  features {}
}

###########################################
# Azure SQL #
###########################################

# SQL Server #

resource "azurerm_mssql_server" "asorkin_rq_mssql_server" {
  name                         = "#{Project.Azure.RandomQuotes.MSSQL.Server}"
  resource_group_name             = "#{Project.Azure.RandomQuotes.ResourceGroup.Name}"
  location                        = "#{Project.Azure.PrimaryLocation.Name}"
  version                      = "12.0"
  administrator_login          = "#{Project.Azure.RandomQuotes.DB.User}"
  administrator_login_password = "#{Project.Azure.RandomQuotes.DB.Password}"
  minimum_tls_version             = "1.2"
  public_network_access_enabled   = true
}

resource "azurerm_mssql_firewall_rule" "allow-octopus-server" {
  depends_on = [ azurerm_mssql_server.asorkin_rq_mssql_server ]
  name                = "allow-octopus-server"
  server_id         = azurerm_mssql_server.asorkin_rq_mssql_server.id
  start_ip_address = "4.227.214.210"
  end_ip_address   = "4.227.214.210"
}

resource "azurerm_mssql_firewall_rule" "allow-azure-resources" {
  depends_on = [ azurerm_mssql_server.asorkin_rq_mssql_server ]
  name                = "allow-azure-resources"
  server_id         = azurerm_mssql_server.asorkin_rq_mssql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}


# SQL Databases #

resource "azurerm_mssql_database" "asorkin_rq_database_dev" {
  depends_on = [ azurerm_mssql_server.asorkin_rq_mssql_server ]
  name           = "RandomQuotes_IaC_Development"
  server_id      = azurerm_mssql_server.asorkin_rq_mssql_server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 1
  read_scale     = false
  sku_name       = "S0"
  zone_redundant = false
  tags = {
    environment = "Development"    	
  }
}

resource "azurerm_mssql_database" "asorkin_rq_database_qa" {
  depends_on = [ azurerm_mssql_server.asorkin_rq_mssql_server ]
  name           = "RandomQuotes_IaC_QA"
  server_id      = azurerm_mssql_server.asorkin_rq_mssql_server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 1
  read_scale     = false
  sku_name       = "S0"
  zone_redundant = false
  tags = {
    environment = "QA"    	
  }
}

resource "azurerm_mssql_database" "asorkin_rq_database_stage" {
  depends_on = [ azurerm_mssql_server.asorkin_rq_mssql_server ]
  name           = "RandomQuotes_IaC_Staging"
  server_id      = azurerm_mssql_server.asorkin_rq_mssql_server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 1
  read_scale     = false
  sku_name       = "S0"
  zone_redundant = false
  tags = {
    environment = "Staging"    	
  }
}

resource "azurerm_mssql_database" "asorkin_rq_database_prod" {
  depends_on = [ azurerm_mssql_server.asorkin_rq_mssql_server ]
  name           = "RandomQuotes_IaC_Production"
  server_id      = azurerm_mssql_server.asorkin_rq_mssql_server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 1
  read_scale     = false
  sku_name       = "S0"
  zone_redundant = false
  tags = {
    environment = "Production"    	
  }
}

###########################################
# Azure Service Plan #
###########################################

resource "azurerm_service_plan" "asorkin_rq_sp" {
  name                         = "#{Project.Azure.RandomQuotes.ServicePlan.Name}"
  resource_group_name          = "#{Project.Azure.RandomQuotes.ResourceGroup.Name}"
  location                     = "#{Project.Azure.PrimaryLocation.Name}"
  os_type                      = "Linux"
  sku_name = "B1"
}

###########################################
# Azure Web Apps #
###########################################

resource "azurerm_linux_web_app" "asorkin_rq_web_app_dev" {
  name                = "asorkin-rq-iac-web-app-development"
  resource_group_name             = "#{Project.Azure.RandomQuotes.ResourceGroup.Name}"
  location                        = "#{Project.Azure.PrimaryLocation.Name}"
  service_plan_id     = azurerm_service_plan.asorkin_rq_sp.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
  }

  tags = {
    octopus-environment = "Development"
  	octopus-space = "#{Octopus.Space.Name}"
  	octopus-role = "#{Project.Azure.RandomQuotes.Role}"
    }
}

resource "azurerm_linux_web_app" "asorkin_rq_web_app_qa" {
  name                = "asorkin-rq-iac-web-app-qa"
  resource_group_name             = "#{Project.Azure.RandomQuotes.ResourceGroup.Name}"
  location                        = "#{Project.Azure.PrimaryLocation.Name}"
  service_plan_id     = azurerm_service_plan.asorkin_rq_sp.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
  }

  tags = {
    octopus-environment = "QA"
  	octopus-space = "#{Octopus.Space.Name}"
  	octopus-role = "#{Project.Azure.RandomQuotes.Role}"
    }
}

resource "azurerm_linux_web_app" "asorkin_rq_web_app_stage" {
  name                = "asorkin-rq-iac-web-app-staging"
  resource_group_name             = "#{Project.Azure.RandomQuotes.ResourceGroup.Name}"
  location                        = "#{Project.Azure.PrimaryLocation.Name}"
  service_plan_id     = azurerm_service_plan.asorkin_rq_sp.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
  }

  tags = {
    octopus-environment = "Staging"
  	octopus-space = "#{Octopus.Space.Name}"
  	octopus-role = "#{Project.Azure.RandomQuotes.Role}"
    }
}

resource "azurerm_linux_web_app" "asorkin_rq_web_app_prod" {
  name                = "asorkin-rq-iac-web-app-production"
  resource_group_name             = "#{Project.Azure.RandomQuotes.ResourceGroup.Name}"
  location                        = "#{Project.Azure.PrimaryLocation.Name}"
  service_plan_id     = azurerm_service_plan.asorkin_rq_sp.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
  }

  tags = {
    octopus-environment = "Production"
  	octopus-space = "#{Octopus.Space.Name}"
  	octopus-role = "#{Project.Azure.RandomQuotes.Role}"
    }
}

###########################################
# Azure Windows Web App Slot #
###########################################

#resource "azurerm_windows_web_app_slot" "stage" {
#  name           = "stage"
#  app_service_id = azurerm_windows_web_app.asorkin_rq_web_app.id

#  site_config {}
#}

#resource "azurerm_windows_web_app_slot" "prod" {
#  name           = "prod"
#  app_service_id = azurerm_windows_web_app.asorkin_rq_web_app.id

#  site_config {}
#}