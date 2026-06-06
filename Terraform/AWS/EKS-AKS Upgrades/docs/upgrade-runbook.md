# Operational Runbook: Kubernetes Upgrades

**Owner**: Platform Engineering
**SLA**: 99.99% Availability
**Severity**: Critical

## Overview
This runbook details the procedures for upgrading EKS and AKS clusters in the regulated FinTech environment. It covers failure scenarios, rollback procedures, and escalation paths.

## Architecture & Constraints
*   **Immutable Infrastructure**: We never patch nodes in place. We replace them.
*   **Zero Downtime**: `PodDisruptionBudgets` must be respected.
*   **DR Policy**: DR (Azure AKS) is upgraded 1 week AFTER Primary (AWS EKS) is stable.

## Failure Scenarios

### Scenario A: Control Plane Upgrade Fails (Timeout/Error)
**Symptoms**:
*   Terraform apply times out after 45m.
*   AWS/Azure console shows "Updating" stuck or "Failed".
**Action**:
1.  **Do NOT cancel** the operation if it's stuck in "Updating". Contact Cloud Support immediately (Enterprise Support Plan).
2.  If cluster is `Failed`:
    *   Check `kubectl get nodes`. If API is responsive, workload might still be running.
    *   **Do NOT** run Terraform destroy.
    *   Escalate to Principal Engineer.

### Scenario B: New Nodes Fail to Join
**Symptoms**:
*   Terraform creates ASG/VMSS, but `kubectl get nodes` does not show new nodes.
**Root Causes**:
*   VPC CNI / Azure CNI incompatibility.
*   Security Group / NSG blocking traffic.
*   IAM Instance Profile missing permissions.
**Action**:
1.  Check CloudInit logs on a new node (SSM Session Manager).
    ```bash
    cat /var/log/cloud-init-output.log
    ```
2.  If nodes are unhealthy, Taint them to prevent scheduling.
3.  Rollback: Destroy the new Node Group via Terraform (Revert commit).

### Scenario C: Workloads Failing on New Nodes
**Symptoms**:
*   Pods scheduled on new nodes enter `CrashLoopBackOff`.
**Action**:
1.  **Stop Draining**: Kill the `drain_nodes.sh` process immediately.
2.  **Uncordon Old Nodes**:
    ```bash
    kubectl uncordon -l version=old
    ```
3.  **Cordon New Nodes**:
    ```bash
    kubectl cordon -l version=new
    ```
4.  **Restart Workloads**: Delete crashing pods so they reschedule to old nodes.

## Rollback Procedure (Emergency)
Execute the `scripts/rollback.sh` script from the bastion host or CI runner.

```bash
./scripts/rollback.sh <cluster-name> "Critical workload failure on v1.29"
```

## Audit & Compliance
*   All Terraform Plans must be stored in S3/Blob Storage (Versioned).
*   Jira Ticket ID must be included in the git commit message.
*   Post-Incident Review (PIR) required for any downtime > 1 minute.
