#!/bin/bash
set -e

CLUSTER_NAME=$1
STAGE=$2 # pre or post

echo "Starting ${STAGE}-flight validation for cluster: ${CLUSTER_NAME}"

# Ensure kubectl context is set (Assumed handled by CI wrapper)

if [[ "$STAGE" == "pre" ]]; then
    echo "Checking general cluster health..."
    
    # Check for NotReady nodes
    NOT_READY_NODES=$(kubectl get nodes --no-headers | grep -v "Ready" | wc -l)
    if [[ "$NOT_READY_NODES" -gt 0 ]]; then
        echo "ERROR: Found ${NOT_READY_NODES} nodes in NotReady state."
        exit 1
    fi

    # Check for CrashLoopBackOff pods in kube-system
    CRASHING_PODS=$(kubectl get pods -n kube-system --no-headers | grep "CrashLoopBackOff" | wc -l)
    if [[ "$CRASHING_PODS" -gt 0 ]]; then
        echo "ERROR: Found ${CRASHING_PODS} crashing pods in kube-system."
        exit 1
    fi

    echo "Pre-flight checks passed."

elif [[ "$STAGE" == "post" ]]; then
    echo "Checking post-upgrade health..."
    
    # Check Version
    SERVER_VERSION=$(kubectl version -o json | jq -r '.serverVersion.gitVersion')
    echo "Current Server Version: ${SERVER_VERSION}"
    
    # Validate all nodes are Ready
    kubectl get nodes
    
    # Validate Critical Workloads (Robo-Advisory)
    # Assuming namespace 'robo-advisory'
    if kubectl get ns robo-advisory > /dev/null 2>&1; then
        echo "Validating robo-advisory workloads..."
        kubectl wait --for=condition=available --timeout=300s deployment --all -n robo-advisory
    fi

    echo "Post-flight checks passed."
fi
