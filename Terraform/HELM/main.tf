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
    registries = [
{
    url      = "oci://localhost:5000"
    username = "username"
    password = "password"
},
{
    url      = "oci://private.registry"
    username = "username"
    password = "password"
}
]
}

