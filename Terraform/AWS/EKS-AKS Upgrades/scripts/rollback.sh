#!/bin/bash

CLUSTER_NAME=$1
REASON=$2

echo "!!! INITIATING ROLLBACK PROCEDURE FOR ${CLUSTER_NAME} !!!"
echo "Reason: ${REASON}"

# 1. Check Control Plane Status
# We cannot automatically downgrade control plane.
echo "Checking Control Plane Status..."
CP_VERSION=$(kubectl version -o json | jq -r '.serverVersion.gitVersion')
echo "Current Control Plane Version: ${CP_VERSION}"
echo "NOTE: Control Plane rollbacks are not automated. If the Control Plane is corrupted, activate DR Disaster Recovery plan."

# 2. Data Plane Rollback (Node Groups)
# Logic: Uncordon OLD nodes, Cordon NEW nodes.

# Identify "Old" nodes (which are the stable ones we want to keep)
# In a rollback scenario, "Old" nodes might be the ones we were trying to drain.
# We need to find nodes that are cordoned and uncordon them.

echo "Attempting to restore traffic to previous stable nodes..."

# Find all nodes that are SchedulingDisabled
CORDONED_NODES=$(kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.unschedulable}{"\n"}{end}' | grep "true" | awk '{print $1}')

if [[ -z "$CORDONED_NODES" ]]; then
    echo "No cordoned nodes found. Manual investigation required."
else
    for NODE in $CORDONED_NODES; do
        echo "Uncordoning ${NODE} (Restoring to service)..."
        kubectl uncordon ${NODE}
    done
fi

# 3. Taint/Cordon New Nodes (The ones that caused failure)
# We assume the "New" nodes are the ones matching the target version that failed validation.
TARGET_VERSION=$(kubectl version -o json | jq -r '.serverVersion.major + "." + .serverVersion.minor' | tr -d 'v')
NEW_NODES=$(kubectl get nodes --no-headers | grep "${TARGET_VERSION}" | awk '{print $1}')

if [[ ! -z "$NEW_NODES" ]]; then
    echo "Isolating potentially bad new nodes..."
    for NODE in $NEW_NODES; do
        echo "Cordoning ${NODE}..."
        kubectl cordon ${NODE}
    done
fi

echo "Rollback script completed. Please verify cluster health immediately."
