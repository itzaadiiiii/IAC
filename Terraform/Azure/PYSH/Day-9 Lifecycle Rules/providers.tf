terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "~> 4.8.0"
        }
    }

    required_version = ">=1.14.0"
}
#Add [required_providers] block to specify the provider and its version. This ensures that Terraform uses the correct provider for Azure resources.

provider "azurerm" {
        features {
        
        }
    
}
