terraform {
    required_providers {
        helm = {
        source  = "hashicorp/helm"
        version = "3.3.0"
        }
    }
}

provider "helm" {
    # Configuration options
    kubernetes = {
    config_path = "~/.kube/config"
    }
}