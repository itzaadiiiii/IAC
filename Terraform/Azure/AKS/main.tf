    ############################################
    # AKS Cluster
    ############################################

    resource "azurerm_kubernetes_cluster" "this" {
    name                = var.name
    resource_group_name = var.resource_group_name
    location            = var.location
    dns_prefix          = replace(var.name, "/[^a-zA-Z0-9-]/", "-")

    kubernetes_version        = var.kubernetes_version
    sku_tier                  = var.sku_tier
    automatic_channel_upgrade = var.automatic_channel_upgrade
    node_os_channel_upgrade   = var.node_os_channel_upgrade

    private_cluster_enabled             = var.private_cluster_enabled
    private_dns_zone_id                 = var.private_cluster_enabled ? var.private_dns_zone_id : null
    api_server_authorized_ip_ranges     = var.private_cluster_enabled ? null : var.api_server_authorized_ip_ranges
    local_account_disabled              = var.local_account_disabled
    role_based_access_control_enabled   = true
    run_command_enabled                 = var.run_command_enabled
    image_cleaner_enabled               = var.image_cleaner_enabled
    image_cleaner_interval_hours        = var.image_cleaner_interval_hours
    cost_analysis_enabled               = var.cost_analysis_enabled
    disk_encryption_set_id              = var.disk_encryption_set_id
    oidc_issuer_enabled                 = var.oidc_issuer_enabled
    workload_identity_enabled           = var.workload_identity_enabled

    # ---------------- System (default) node pool ----------------
    default_node_pool {
        name                 = var.system_node_pool_name
        vm_size              = var.system_node_pool_vm_size
        os_sku               = var.system_node_pool_os_sku
        vnet_subnet_id       = var.vnet_subnet_id
        pod_subnet_id        = var.pod_subnet_id
        zones                = var.system_node_pool_availability_zones
        max_pods             = var.system_node_pool_max_pods
        os_disk_size_gb      = var.system_node_pool_os_disk_size_gb
        os_disk_type         = var.system_node_pool_os_disk_type
        only_critical_addons_enabled = true

        auto_scaling_enabled = true
        node_count           = var.system_node_pool_node_count
        min_count             = var.system_node_pool_min_count
        max_count             = var.system_node_pool_max_count

        upgrade_settings {
        max_surge = "33%"
        }

        tags = var.tags
    }

    # ---------------- Identity ----------------
    identity {
        type         = "UserAssigned"
        identity_ids = var.identity_ids
    }

    kubelet_identity {
        client_id                 = var.kubelet_identity_client_id
        object_id                 = var.kubelet_identity_object_id
        user_assigned_identity_id = var.kubelet_identity_id
    }

    # ---------------- Entra ID / Azure RBAC ----------------
    azure_active_directory_role_based_access_control {
        tenant_id              = data.azurerm_client_config.current.tenant_id
        azure_rbac_enabled     = var.azure_rbac_enabled
        admin_group_object_ids = var.aad_admin_group_object_ids
    }

    # ---------------- Networking ----------------
    network_profile {
        network_plugin      = var.network_plugin
        network_plugin_mode = var.network_plugin_mode == "overlay" ? "overlay" : null
        network_policy      = var.network_policy
        pod_cidr            = var.network_plugin_mode == "overlay" ? var.pod_cidr : null
        service_cidr        = var.service_cidr
        dns_service_ip       = var.dns_service_ip
        outbound_type        = var.outbound_type
        load_balancer_sku    = var.load_balancer_sku
    }

    # ---------------- Add-ons ----------------
    key_vault_secrets_provider {
        secret_rotation_enabled  = var.key_vault_secrets_provider_enabled ? var.secret_rotation_enabled : null
        secret_rotation_interval = var.key_vault_secrets_provider_enabled ? var.secret_rotation_interval : null
    }

    dynamic "microsoft_defender" {
        for_each = var.defender_enabled ? [1] : []
        content {
        log_analytics_workspace_id = var.log_analytics_workspace_id
        }
    }

    oms_agent {
        log_analytics_workspace_id      = var.log_analytics_workspace_id
        msi_auth_for_monitoring_enabled = true
    }

    dynamic "monitor_metrics" {
        for_each = var.monitor_metrics_enabled ? [1] : []
        content {
        annotations_allowed = var.monitor_metrics_annotations_allowed
        labels_allowed       = var.monitor_metrics_labels_allowed
        }
    }

    azure_policy_enabled             = var.azure_policy_enabled
    http_application_routing_enabled = var.http_application_routing_enabled
    open_service_mesh_enabled        = var.open_service_mesh_enabled

    dynamic "ingress_application_gateway" {
        for_each = var.ingress_application_gateway_enabled ? [1] : []
        content {
        gateway_id   = var.ingress_application_gateway_id
        subnet_cidr  = var.ingress_application_gateway_id == null ? var.ingress_application_gateway_subnet_cidr : null
        }
    }

    # ---------------- Maintenance windows ----------------
    dynamic "maintenance_window_auto_upgrade" {
        for_each = var.maintenance_window_enabled ? [1] : []
        content {
        frequency   = "Weekly"
        interval    = 1
        day_of_week = var.maintenance_window_day
        start_time  = format("%02d:00", var.maintenance_window_start_hour)
        duration    = 4
        }
    }

    dynamic "maintenance_window_node_os" {
        for_each = var.maintenance_window_enabled ? [1] : []
        content {
        frequency   = "Weekly"
        interval    = 1
        day_of_week = var.node_os_maintenance_window_day
        start_time  = format("%02d:00", var.node_os_maintenance_window_start_hour)
        duration    = 4
        }
    }

    tags = var.tags

    lifecycle {
        ignore_changes = [
        # Autoscaler manages this after initial creation
        default_node_pool[0].node_count,
        ]
    }
    }

    data "azurerm_client_config" "current" {}

    ############################################
    # User (additional) node pools
    ############################################

    resource "azurerm_kubernetes_cluster_node_pool" "user" {
    for_each = var.user_node_pools

    name                  = substr(each.key, 0, 12)
    kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id

    vm_size         = each.value.vm_size
    os_sku          = each.value.os_sku
    os_type         = "Linux"
    mode            = each.value.mode
    priority        = each.value.priority
    spot_max_price  = each.value.priority == "Spot" ? each.value.spot_max_price : null
    eviction_policy = each.value.priority == "Spot" ? "Delete" : null

    vnet_subnet_id  = coalesce(each.value.vnet_subnet_id, var.vnet_subnet_id)
    pod_subnet_id   = var.pod_subnet_id
    zones           = each.value.availability_zones
    max_pods        = each.value.max_pods
    os_disk_size_gb = each.value.os_disk_size_gb
    os_disk_type    = each.value.os_disk_type

    auto_scaling_enabled = true
    node_count            = each.value.node_count
    min_count              = each.value.min_count
    max_count              = each.value.max_count

    node_labels = merge(
        each.value.node_labels,
        each.value.priority == "Spot" ? { "kubernetes.azure.com/scalesetpriority" = "spot" } : {}
    )

    node_taints = concat(
        each.value.node_taints,
        each.value.priority == "Spot" ? ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"] : []
    )

    upgrade_settings {
        max_surge = "33%"
    }

    tags = var.tags

    lifecycle {
        ignore_changes = [node_count]
    }
    }

    ############################################
    # Diagnostic Settings
    ############################################

    resource "azurerm_monitor_diagnostic_setting" "aks" {
    name                       = "${var.name}-diag"
    target_resource_id         = azurerm_kubernetes_cluster.this.id
    log_analytics_workspace_id = var.log_analytics_workspace_id

    dynamic "enabled_log" {
        for_each = var.diagnostic_log_categories
        content {
        category = enabled_log.value

        dynamic "retention_policy" {
            for_each = var.log_retention_days > 0 ? [1] : []
            content {
            enabled = true
            days    = var.log_retention_days
            }
        }
        }
    }

    dynamic "metric" {
        for_each = var.diagnostic_metric_categories
        content {
        category = metric.value
        enabled  = true
        }
    }
    }

