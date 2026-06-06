terraform {
  required_version = ">= 1.5.0"
  
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "fintechstate"
    container_name       = "tfstate"
    key                  = "aks.dr.tfstate"
  }
}

provider "azurerm" {
  features {}
}

module "aks_dr_secondary" {
  source = "../../modules/aks"

  cluster_name        = "fintech-dr-secondary-01"
  location            = "East US"
  resource_group_name = "rg-fintech-dr-01"
  kubernetes_version  = "1.30" # Must lag or match primary
  environment         = "dr"
  vnet_subnet_id      = "/subscriptions/.../subnets/aks-subnet"
}
