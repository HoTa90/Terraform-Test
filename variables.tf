variable "resource_group_name" {
  type        = string
  description = "Name of the resource group in Azure."
}

variable "resource_group_location" {
  type        = string
  description = "Location (region) of the resource group in Azure."
}

variable "app_service_plan_name" {
  type        = string
  description = "Name of the Azure App Service plan."
}

variable "app_service_name" {
  type        = string
  description = "Name of the Azure App Service (Web App)."
}

variable "sql_server_name" {
  type        = string
  description = "Name of the Azure SQL Server."
}

variable "sql_database_name" {
  type        = string
  description = "Name of the Azure SQL Database."
}

variable "sql_admin_login_username" {
  type        = string
  description = "Administrator login username for the Azure SQL Server."
}

variable "sql_admin_login_password" {
  type        = string
  description = "Administrator login password for the Azure SQL Server."
  sensitive   = true
}

variable "firewall_rule_name" {
  type        = string
  description = "Name of the Azure SQL Server firewall rule."
}

variable "github_repo_url" {
  type        = string
  description = "GitHub repository URL used for source control deployment to the Web App."
}
