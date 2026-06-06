#!/bin/bash
set -e

CLUSTER_NAME=$1
PROVIDER=$2 # aws or aks (optional, for specific logic)

echo "Starting Node Drain Procedure for ${CLUSTER_NAME}..."

# 1. Determine Target Version from Control Plane
TARGET_VERSION=$(kubectl version -o json | jq -r '.serverVersion.major + "." + .serverVersion.minor' | tr -d 'v')
echo "Target Control Plane Version: ${TARGET_VERSION}"

# 2. Identify Old Nodes (Nodes not matching target version)
# We look for nodes where the Kubelet version does not contain the target version string
OLD_NODES=$(kubectl get nodes --no-headers | grep -v "${TARGET_VERSION}" | awk '{print $1}')

if [[ -z "$OLD_NODES" ]]; then
    echo "No old nodes found to drain. Cluster is up to date."
    exit 0
fi

echo "Found old nodes to drain:"
echo "$OLD_NODES"

# 3. Drain Loop
for NODE in $OLD_NODES; do
    echo "------------------------------------------------"
    echo "Processing Node: ${NODE}"
    
    # Check if node is already Ready,SchedulingDisabled (Cordoned)
    STATUS=$(kubectl get node ${NODE} -o jsonpath='{.spec.unschedulable}')
    
    if [[ "$STATUS" != "true" ]]; then
        echo "Cordoning ${NODE}..."
        kubectl cordon ${NODE}
    fi

    echo "Draining ${NODE}..."
    # --ignore-daemonsets: DaemonSets are restarted on new nodes automatically
    # --delete-emptydir-data: Required for some pods using local storage
    if kubectl drain ${NODE} --ignore-daemonsets --delete-emptydir-data --timeout=300s; then
        echo "Successfully drained ${NODE}."
    else
        echo "ERROR: Failed to drain ${NODE}. Halting for manual intervention."
        # Optional: Send Slack Alert here
        exit 1
    fi
    
    # Wait a bit between nodes for stability
    echo "Waiting 30s before next node..."
    sleep 30
done

echo "All old nodes drained successfully."
echo "Terraform will handle the deletion of these nodes in the next apply or cleanup phase."
