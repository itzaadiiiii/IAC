provider "azurerm" {
  features {}
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name       = "system${replace(var.kubernetes_version, ".", "")}"
    node_count = 2
    vm_size    = "Standard_D4s_v5" # System components
    vnet_subnet_id = var.vnet_subnet_id
    only_critical_addons_enabled = true
    
    # Enable Auto-Scaling
    auto_scaling_enabled = true
    min_count           = 2
    max_count           = 4
    
    upgrade_settings {
      max_surge = "33%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  tags = {
    Environment = var.environment
  }
}

# Immutable Node Pools - General
# Naming limitation: AKS node pool name must be 12 chars max, lowercase alphanumeric.
# Strategy: "gn" + simplified version. e.g., gn129 (general 1.29)
resource "azurerm_kubernetes_cluster_node_pool" "general" {
  name                  = "gn${replace(var.kubernetes_version, ".", "")}"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = "Standard_D8as_v5" # Approx m6a.2xlarge
  node_count            = 2
  vnet_subnet_id        = var.vnet_subnet_id
  
  mode = "User"
  
  node_labels = {
    workload = "general"
  }
  
  # Prevent in-place upgrades by forcing replacement if name changes (name is tied to version)
  lifecycle {
    create_before_destroy = true
  }
}

# Immutable Node Pools - CPU
resource "azurerm_kubernetes_cluster_node_pool" "cpu" {
  name                  = "cp${replace(var.kubernetes_version, ".", "")}"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = "Standard_F4s_v2" # Approx c5.xlarge
  node_count            = 1
  vnet_subnet_id        = var.vnet_subnet_id
  
  mode = "User"

  node_labels = {
    workload = "cpu-intensive"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Immutable Node Pools - ML
resource "azurerm_kubernetes_cluster_node_pool" "ml" {
  name                  = "ml${replace(var.kubernetes_version, ".", "")}"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = "Standard_E4s_v3" # Approx r5.xlarge
  node_count            = 1
  vnet_subnet_id        = var.vnet_subnet_id
  
  mode = "User"

  node_labels = {
    workload = "ml-workload"
  }
  
  node_taints = [
    "workload=ml:NoSchedule"
  ]

  lifecycle {
    create_before_destroy = true
  }
}
