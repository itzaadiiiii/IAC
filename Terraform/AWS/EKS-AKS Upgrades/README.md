# Enterprise Kubernetes Upgrade Automation

## High-Level Execution Flow

1.  **Pre-Flight Checks (Automated)**
    *   Validate cloud credentials (Vault).
    *   Check current cluster health status.
    *   Verify target version compatibility (deprecation checks).
    *   Snapshot Etcd (where applicable/managed).

2.  **Infrastructure Provisioning (Terraform)**
    *   **Plan**: Generate Terraform plan for control plane version update.
    *   **Approval**: Manual gate for Production/DR.
    *   **Apply (Control Plane)**: Upgrade EKS/AKS Control Plane.
    *   **Apply (Data Plane)**:
        *   Provision NEW Node Groups/Pools with new K8s version AMI.
        *   Wait for new nodes to be Ready.

3.  **Workload Migration (Graceful)**
    *   Taint OLD nodes to prevent new scheduling.
    *   Cordon OLD nodes.
    *   Drain OLD nodes (evict pods to new nodes).
    *   Wait for PDB (Pod Disruption Budget) compliance.

4.  **Validation**
    *   Run synthetic checks (smoke tests).
    *   Verify microservices health.

5.  **Cleanup**
    *   Destroy OLD Node Groups/Pools via Terraform.

6.  **Notification**
    *   Slack alerts at Start, Success, or Failure.

7.  **Rollback Strategy**
    *   If Control Plane fails: Restore from backup (cloud provider dependency) or switch DNS to DR.
    *   If Data Plane fails: Cordon NEW nodes, Uncordon OLD nodes, Redeploy workloads.

## Repository Structure

```tree
.
├── infrastructure
│   ├── modules
│   │   ├── eks            # EKS Enterprise Module
│   │   └── aks            # AKS Enterprise Module
│   └── live
│       ├── dev            # Environment: Dev
│       ├── qa             # Environment: QA
│       ├── stage          # Environment: Stage
│       ├── prod           # Environment: Prod (20 clusters)
│       └── dr             # Environment: DR (Secondary)
├── pipelines
│   ├── jenkins            # Jenkinsfiles for AWS/EKS
│   └── gitlab             # GitLab CI for Azure/AKS/DR
├── scripts
│   ├── validate_cluster.sh # Pre/Post health checks
│   ├── drain_nodes.sh      # Safely drain nodes
│   └── rollback.sh         # Rollback logic
├── docs
│   ├── steps.md            # Detailed step-by-step guide
│   └── upgrade-runbook.md  # Operational runbook
└── templates
    └── slack               # Notification templates
```
