resource "azurerm_kubernetes_cluster_node_pool" "general" {
  name                  = "gn${replace(var.kubernetes_version, ".", "")}" # e.g. gn129
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = "Standard_D8as_v5" # Approx m6a.2xlarge
  
  # Prevent in-place upgrades by forcing replacement if name changes
  lifecycle {
    create_before_destroy = true
  }
}# Kubernetes Upgrade Steps (Enterprise Standard)

**Target Version**: Kubernetes 1.30 (Latest Enterprise Stable)
**Scope**: EKS (Primary) & AKS (DR)

This document outlines the **exact sequential steps** required to upgrade the Kubernetes control plane and data plane (nodes) with zero downtime. 

---

## ⚠️ Critical Rules of Engagement
1.  **Sequence Matters**: Do NOT skip steps. The order is designed to prevent data loss and service outage.
2.  **No In-Place Upgrades**: We never patch existing nodes. We create NEW nodes and move workloads.
3.  **DR Last**: The DR cluster (AKS) is upgraded **only after** the Primary (EKS) is stable for 7 days.

---

## Phase 1: Preparation (T-Minus 24 Hours)

### Step 1.1: Verify Tooling & Access
**Who**: Platform Engineer
**Action**: Ensure your local environment matches the CI/CD runner version.
```bash
# Check Terraform version (Must be >= 1.5.0)
terraform version

# Check kubectl version (Must be +/- 1 minor version of target 1.30)
kubectl version --client
```

### Step 1.2: Deprecation Check
**Who**: Automated / Platform Engineer
**Action**: Scan the cluster for APIs removed in 1.30.
**Why**: 1.30 may remove APIs deprecated in 1.29.
```bash
# Run Kubent (Kube No Trouble)
kubent -c <cluster-context> -t 1.30
```
*   **Result**: If any deprecated APIs are found (e.g., old `HorizontalPodAutoscaler` versions), **STOP**. Fix the manifests in the application repositories first.

### Step 1.3: Check Cloud Quotas
**Who**: Platform Engineer
**Action**: Verify sufficient capacity for Blue/Green node deployment.
**Why**: We will temporarily double the node count.
*   **AWS**: Check EC2 vCPU Limits (On-Demand).
*   **Azure**: Check vCPU Quotas for the region.

---

## Phase 2: Execution - Primary EKS (T-0)

### Step 2.1: Initiate Upgrade Pipeline
**Who**: Platform Engineer
**Action**: Trigger Jenkins Job `eks-upgrade-prod`.
*   **Input**: `CLUSTER_NAME=fintech-prod-primary-01`, `TARGET_VERSION=1.30`.

### Step 2.2: Automated Pre-Flight (CI)
**Who**: Jenkins System
**Action**: The pipeline runs `scripts/validate_cluster.sh pre`.
*   **Checks**:
    1.  Are all nodes `Ready`?
    2.  Are there `0` crashing pods in `kube-system`?
    3.  Is the Vault connection active?
*   **Outcome**: If this fails, the pipeline halts immediately.

### Step 2.3: Terraform Plan (Control Plane)
**Who**: Jenkins System
**Action**: Generates `tfplan`.
**What happens**:
*   Terraform detects the change from `1.29` -> `1.30`.
*   Terraform plans to update the EKS Control Plane.
*   Terraform plans to create **NEW** Node Groups (e.g., `general-1-30`, `cpu-1-30`) because the name includes the version.
*   Terraform plans to **KEEP** Old Node Groups (e.g., `general-1-29`) because we haven't removed them from code yet (or lifecycle prevents destroy).

### Step 2.4: Manual Approval Gate
**Who**: Principal Engineer
**Action**: Review the `tfplan` in Jenkins artifacts.
**Verify**:
*   `module.eks.aws_eks_cluster.this` will be updated in-place.
*   `module.eks.aws_eks_node_group.general-1-30` will be created.
*   **No Destructive Actions** on existing nodes should be planned yet.
**Decision**: Click **Proceed** in Jenkins.

### Step 2.5: Apply - Control Plane & New Nodes
**Who**: Jenkins System
**Action**: Runs `terraform apply`.
**Duration**: ~45 minutes.
**What happens**:
1.  AWS updates the EKS Control Plane to 1.30.
2.  AWS provisions new EC2 instances for the 1.30 Node Groups.
3.  New nodes join the cluster.

### Step 2.6: Post-Apply Health Check
**Who**: Jenkins System
**Action**: Verifies that new nodes are `Ready`.
```bash
kubectl get nodes
# Expect: Mix of v1.29 and v1.30 nodes. All Ready.
```

---

## Phase 3: Workload Migration (The "Switch")

### Step 3.1: Cordon & Drain Old Nodes
**Who**: Jenkins System (executing `scripts/drain_nodes.sh`)
**Action**: Sequentially drain v1.29 nodes.
**Detailed Flow**:
1.  **Identify**: Script lists all nodes with version `< 1.30`.
2.  **Taint**: Marks old nodes as `NoSchedule`.
3.  **Evict**: Runs `kubectl drain <node>`.
    *   Pods receive `SIGTERM`.
    *   Pods shut down gracefully.
    *   ReplicaSet creates new Pods.
    *   Scheduler places new Pods on **v1.30** nodes (since old ones are tainted).
4.  **Wait**: Script waits for PDB (Pod Disruption Budget) compliance between drains.

### Step 3.2: Validation (Smoke Tests)
**Who**: Jenkins System
**Action**: Runs `scripts/validate_cluster.sh post`.
**What**:
*   Checks if `robo-advisory` microservices are `Running`.
*   Checks if `coredns`, `vpc-cni`, `kube-proxy` are healthy.

---

## Phase 4: Cleanup (T+2 Hours)

### Step 4.1: Remove Old Infrastructure
**Who**: Platform Engineer
**Action**: Update the Terraform code to remove the old node groups definition (or if using dynamic maps, update the variable).
**Note**: In our current immutable setup, the "Old" node groups might still exist in state.
1.  **Commit**: Remove `1.29` specific configurations if hardcoded, or rely on the `drain` completion.
2.  **Apply**: Run Terraform Apply again to destroy the old ASGs.
    *   *Note: In a pure automated flow, the pipeline usually handles the destruction of the old node groups if they are defined dynamically, or this is a separate "Cleanup" stage.*

---

## Phase 5: DR Upgrade (T+1 Week)

### Step 5.1: Repeat for AKS
**Who**: Platform Engineer
**Action**: Trigger GitLab CI pipeline for `infrastructure/live/dr`.
**Process**:
1.  Same logic applies: Upgrade Control Plane -> Create New Node Pools -> Drain Old Pools -> Delete Old Pools.
2.  **Specific AKS Check**: Ensure `PDB`s allow for eviction, as Azure upgrades can sometimes be aggressive.

---

## Emergency Rollback Steps

**Trigger**: If workloads fail to start on 1.30 nodes.

1.  **Stop the Drain**: Kill the Jenkins job.
2.  **Uncordon Old Nodes**:
    ```bash
    kubectl uncordon -l version=1.29
    ```
3.  **Cordon New Nodes**:
    ```bash
    kubectl cordon -l version=1.30
    ```
4.  **Restart Pods**: Delete pending/crashing pods so they return to 1.29 nodes.
5.  **Assess**: If Control Plane is already 1.30, it is backward compatible with 1.29 nodes. We can stay in this mixed state while debugging.
