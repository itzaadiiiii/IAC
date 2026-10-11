# This file is used to configure the backend for Terraform state storage. The backend is responsible for storing the state of your Terraform-managed infrastructure, allowing you to collaborate with others and manage your infrastructure more effectively.
terraform {
    backend "azurerm" {
        resource_group_name  = "tfstate-day04"  # Can be passed via `-backend-config=`"resource_group_name=<resource group name>"` in the `init` command.
        storage_account_name = "day0417691"                      # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
        container_name       = "tfstate"                       # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
        key                  = "dev.terraform.tfstate"        # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.
    }
    }
