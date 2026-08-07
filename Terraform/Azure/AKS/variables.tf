    ############################################
    # General
    ############################################

    variable "name" {
    description = "Name of the AKS cluster."
    type        = string
    }

    variable "resource_group_name" {
    description = "Name of the resource group where AKS will be deployed."
    type        = string
    }

    variable "location" {
    description = "Azure region for the AKS cluster."
    type        = string
    }

    variable "tags" {
    description = "Tags applied to all resources created by this module."
    type        = map(string)
    default     = {}
    }

    variable "environment" {
    description = "Environment name (dev, qa, stage, prod, dr). Used in naming and conditional logic."
    type        = string
    }

    ############################################
    # Kubernetes version / SKU
    ############################################

    variable "kubernetes_version" {
    description = "Kubernetes version for the control plane and default node pool."
    type        = string
    default     = "1.33"
    }

    variable "sku_tier" {
    description = "AKS SKU tier. Free, Standard (uptime SLA) or Premium (long-term support)."
    type        = string
    default     = "Standard"

    validation {
        condition     = contains(["Free", "Standard", "Premium"], var.sku_tier)
        error_message = "sku_tier must be one of: Free, Standard, Premium."
    }
    }

    variable "automatic_channel_upgrade" {
    description = "Automatic upgrade channel. Use 'patch' or 'node-image' for prod, 'stable' or 'rapid' for lower envs."
    type        = string
    default     = "patch"
    }

    variable "node_os_channel_upgrade" {
    description = "Node OS auto-upgrade channel."
    type        = string
    default     = "NodeImage"
    }

    ############################################
    # Networking
    ############################################

    variable "vnet_subnet_id" {
    description = "Subnet ID for the system node pool (and default for user pools unless overridden)."
    type        = string
    }

    variable "pod_subnet_id" {
    description = "Optional dedicated pod subnet ID (only used with Azure CNI in non-overlay pod-subnet mode). Leave null for CNI Overlay."
    type        = string
    default     = null
    }

    variable "network_plugin" {
    description = "Network plugin. Use 'azure' for Azure CNI."
    type        = string
    default     = "azure"
    }

    variable "network_plugin_mode" {
    description = "Network plugin mode. Set to 'overlay' for Azure CNI Overlay."
    type        = string
    default     = "overlay"
    }

    variable "network_policy" {
    description = "Network policy engine: 'azure', 'calico', or null to disable."
    type        = string
    default     = "azure"
    }

    variable "pod_cidr" {
    description = "CIDR used for pod IPs when running Azure CNI Overlay (must not overlap with VNet)."
    type        = string
    default     = "10.244.0.0/16"
    }

    variable "service_cidr" {
    description = "CIDR for Kubernetes services."
    type        = string
    default     = "10.245.0.0/16"
    }

    variable "dns_service_ip" {
    description = "IP address within service_cidr used for cluster DNS (kube-dns/CoreDNS)."
    type        = string
    default     = "10.245.0.10"
    }

    variable "outbound_type" {
    description = "Outbound routing method: 'loadBalancer', 'userDefinedRouting', 'managedNATGateway', or 'userAssignedNATGateway'."
    type        = string
    default     = "userDefinedRouting"
    }

    variable "load_balancer_sku" {
    description = "SKU for the AKS load balancer."
    type        = string
    default     = "standard"
    }

    variable "private_cluster_enabled" {
    description = "Deploy AKS as a private cluster (no public API server endpoint)."
    type        = bool
    default     = true
    }

    variable "private_dns_zone_id" {
    description = "Private DNS zone ID for the private cluster API server (or 'System' / 'None'). Required when private_cluster_enabled = true and you want Terraform-managed DNS."
    type        = string
    default     = "System"
    }

    variable "api_server_authorized_ip_ranges" {
    description = "CIDR ranges allowed to reach the public API server when private_cluster_enabled = false."
    type        = list(string)
    default     = []
    }

    ############################################
    # Identity / RBAC / Entra ID
    ############################################

    variable "identity_ids" {
    description = "List of User Assigned Managed Identity IDs to attach to the cluster control plane."
    type        = list(string)
    }

    variable "kubelet_identity_id" {
    description = "Resource ID of the User Assigned Identity used as the kubelet identity."
    type        = string
    }

    variable "kubelet_identity_client_id" {
    description = "Client ID of the kubelet User Assigned Identity."
    type        = string
    }

    variable "kubelet_identity_object_id" {
    description = "Object (principal) ID of the kubelet User Assigned Identity."
    type        = string
    }

    variable "azure_rbac_enabled" {
    description = "Enable Azure RBAC for Kubernetes authorization (in addition to Entra ID auth)."
    type        = bool
    default     = true
    }

    variable "aad_admin_group_object_ids" {
    description = "Entra ID (Azure AD) group object IDs granted cluster-admin via Azure RBAC / kubeconfig admin role."
    type        = list(string)
    default     = []
    }

    variable "local_account_disabled" {
    description = "Disable local Kubernetes accounts (kubeconfig admin via static credentials). Recommended true for prod."
    type        = bool
    default     = true
    }

    variable "workload_identity_enabled" {
    description = "Enable Azure AD Workload Identity (federated credentials for pods)."
    type        = bool
    default     = true
    }

    variable "oidc_issuer_enabled" {
    description = "Enable the OIDC issuer endpoint (required for Workload Identity)."
    type        = bool
    default     = true
    }

    ############################################
    # System node pool
    ############################################

    variable "system_node_pool_name" {
    description = "Name of the default/system node pool."
    type        = string
    default     = "system"
    }

    variable "system_node_pool_vm_size" {
    description = "VM SKU for the system node pool."
    type        = string
    default     = "Standard_D4s_v5"
    }

    variable "system_node_pool_os_sku" {
    description = "OS SKU for system node pool nodes."
    type        = string
    default     = "AzureLinux"
    }

    variable "system_node_pool_node_count" {
    description = "Initial node count for the system pool (ignored once autoscaling is active, used as starting point)."
    type        = number
    default     = 3
    }

    variable "system_node_pool_min_count" {
    description = "Minimum node count for system pool autoscaling."
    type        = number
    default     = 3
    }

    variable "system_node_pool_max_count" {
    description = "Maximum node count for system pool autoscaling."
    type        = number
    default     = 5
    }

    variable "system_node_pool_max_pods" {
    description = "Max pods per node on the system pool."
    type        = number
    default     = 30
    }

    variable "system_node_pool_availability_zones" {
    description = "Availability zones for the system node pool."
    type        = list(string)
    default     = ["1", "2", "3"]
    }

    variable "system_node_pool_os_disk_size_gb" {
    description = "OS disk size (GB) for system pool nodes."
    type        = number
    default     = 128
    }

    variable "system_node_pool_os_disk_type" {
    description = "OS disk type for system pool nodes (Managed or Ephemeral)."
    type        = string
    default     = "Ephemeral"
    }

    ############################################
    # User node pool(s)
    ############################################

    variable "user_node_pools" {
    description = <<-EOT
        Map of additional (user) node pools to create. Key = pool name.
        Example:
        {
        general = {
            vm_size              = "Standard_D8s_v5"
            os_sku               = "AzureLinux"
            node_count           = 5
            min_count            = 5
            max_count            = 15
            max_pods             = 30
            os_disk_size_gb      = 128
            os_disk_type         = "Ephemeral"
            availability_zones   = ["1", "2", "3"]
            mode                 = "User"
            priority             = "Regular"   # or "Spot"
            spot_max_price       = -1
            node_labels          = {}
            node_taints          = []
            vnet_subnet_id       = null        # falls back to var.vnet_subnet_id
        }
        }
    EOT
    type = map(object({
        vm_size            = string
        os_sku             = optional(string, "AzureLinux")
        node_count         = number
        min_count          = number
        max_count          = number
        max_pods           = optional(number, 30)
        os_disk_size_gb    = optional(number, 128)
        os_disk_type       = optional(string, "Ephemeral")
        availability_zones = optional(list(string), ["1", "2", "3"])
        mode               = optional(string, "User")
        priority           = optional(string, "Regular")
        spot_max_price     = optional(number, -1)
        node_labels        = optional(map(string), {})
        node_taints        = optional(list(string), [])
        vnet_subnet_id     = optional(string, null)
    }))
    default = {
        general = {
        vm_size            = "Standard_D8s_v5"
        node_count         = 5
        min_count          = 5
        max_count          = 15
        max_pods           = 30
        os_disk_size_gb    = 128
        os_disk_type       = "Ephemeral"
        availability_zones = ["1", "2", "3"]
        mode               = "User"
        priority           = "Regular"
        spot_max_price     = -1
        node_labels        = {}
        node_taints        = []
        vnet_subnet_id     = null
        }
    }
    }

    ############################################
    # Add-ons
    ############################################

    variable "key_vault_secrets_provider_enabled" {
    description = "Enable Azure Key Vault Secrets Store CSI Driver add-on."
    type        = bool
    default     = true
    }

    variable "secret_rotation_enabled" {
    description = "Enable automatic secret rotation for the Key Vault CSI driver."
    type        = bool
    default     = true
    }

    variable "secret_rotation_interval" {
    description = "Interval for Key Vault CSI driver secret rotation polling."
    type        = string
    default     = "2m"
    }

    variable "azure_policy_enabled" {
    description = "Enable the Azure Policy add-on (Gatekeeper)."
    type        = bool
    default     = true
    }

    variable "http_application_routing_enabled" {
    description = "Enable HTTP application routing add-on (not recommended for production)."
    type        = bool
    default     = false
    }

    variable "open_service_mesh_enabled" {
    description = "Enable Open Service Mesh add-on."
    type        = bool
    default     = false
    }

    variable "ingress_application_gateway_enabled" {
    description = "Enable AGIC (Application Gateway Ingress Controller) add-on."
    type        = bool
    default     = false
    }

    variable "ingress_application_gateway_id" {
    description = "Resource ID of an existing Application Gateway to use with AGIC. Leave null to let AKS create one via gateway_name/subnet_cidr."
    type        = string
    default     = null
    }

    variable "ingress_application_gateway_subnet_cidr" {
    description = "Subnet CIDR AKS should use to auto-provision an Application Gateway for AGIC (only used if ingress_application_gateway_id is null)."
    type        = string
    default     = null
    }

    ############################################
    # Monitoring
    ############################################

    variable "log_analytics_workspace_id" {
    description = "Resource ID of the Log Analytics Workspace used by Azure Monitor / OMS Agent."
    type        = string
    }

    variable "monitor_metrics_enabled" {
    description = "Enable Azure Monitor managed service for Prometheus."
    type        = bool
    default     = true
    }

    variable "monitor_metrics_annotations_allowed" {
    description = "Kubernetes annotations allowed to be collected by Managed Prometheus."
    type        = string
    default     = null
    }

    variable "monitor_metrics_labels_allowed" {
    description = "Kubernetes labels allowed to be collected by Managed Prometheus."
    type        = string
    default     = null
    }

    variable "grafana_resource_id" {
    description = "Resource ID of the Azure Managed Grafana instance to link with Managed Prometheus. Leave null if not linking."
    type        = string
    default     = null
    }

    ############################################
    # Defender for Containers
    ############################################

    variable "defender_enabled" {
    description = "Enable Microsoft Defender for Containers on the cluster."
    type        = bool
    default     = true
    }

    ############################################
    # Maintenance windows
    ############################################

    variable "maintenance_window_enabled" {
    description = "Configure a maintenance window for cluster auto-upgrades."
    type        = bool
    default     = true
    }

    variable "maintenance_window_day" {
    description = "Day of week for the auto-upgrade maintenance window."
    type        = string
    default     = "Sunday"
    }

    variable "maintenance_window_start_hour" {
    description = "Start hour (0-23) for the auto-upgrade maintenance window."
    type        = number
    default     = 2
    }

    variable "node_os_maintenance_window_day" {
    description = "Day of week for the node OS auto-upgrade maintenance window."
    type        = string
    default     = "Sunday"
    }

    variable "node_os_maintenance_window_start_hour" {
    description = "Start hour (0-23) for the node OS auto-upgrade maintenance window."
    type        = number
    default     = 4
    }

    ############################################
    # Diagnostics
    ############################################

    variable "diagnostic_log_categories" {
    description = "Diagnostic log categories to enable on the AKS cluster."
    type        = list(string)
    default = [
        "kube-apiserver",
        "kube-audit",
        "kube-audit-admin",
        "kube-controller-manager",
        "kube-scheduler",
        "cluster-autoscaler",
        "cloud-controller-manager",
        "guard",
        "csi-azuredisk-controller",
        "csi-azurefile-controller",
        "csi-snapshot-controller",
    ]
    }

    variable "diagnostic_metric_categories" {
    description = "Diagnostic metric categories to enable on the AKS cluster."
    type        = list(string)
    default     = ["AllMetrics"]
    }

    variable "log_retention_days" {
    description = "Retention in days for diagnostic logs sent to the Log Analytics Workspace (0 = workspace default retention)."
    type        = number
    default     = 30
    }

    ############################################
    # Storage / other
    ############################################

    variable "disk_encryption_set_id" {
    description = "Resource ID of a Disk Encryption Set for customer-managed key encryption of node OS/data disks. Leave null to use platform-managed keys."
    type        = string
    default     = null
    }

    variable "run_command_enabled" {
    description = "Enable 'az aks command invoke' (run command) support."
    type        = bool
    default     = false
    }

    variable "image_cleaner_enabled" {
    description = "Enable the AKS Image Cleaner controller."
    type        = bool
    default     = true
    }

    variable "image_cleaner_interval_hours" {
    description = "Interval (hours) at which Image Cleaner runs."
    type        = number
    default     = 48
    }

    variable "cost_analysis_enabled" {
    description = "Enable AKS cost analysis add-on (requires sku_tier = Standard or Premium)."
    type        = bool
    default     = true
    }
