terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.26.0"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id = "a5ddb52f-ffc2-4057-b3c6-67e57b8acb6c"
  resource_provider_registrations = "none"
}