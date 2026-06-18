# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }

  required_version = ">= 1.14.0"
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}


# Create a resource group
resource "azurerm_resource_group" "dev_eu_north_rg" {
  name     = "Terraform-RG"
  location = "South India"
}
