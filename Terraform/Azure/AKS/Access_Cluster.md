# AKS Cluster Access Guide

This guide explains how to access an **Azure Kubernetes Service (AKS)** cluster using `kubectl`, both with **local/admin credentials** and with **Microsoft Entra ID (SSO)**.

> **Recommended for production:** Use Microsoft Entra ID (SSO) for user access rather than local admin credentials. Microsoft recommends Entra ID-based authentication for AKS because it provides centralized identity, MFA, Conditional Access, and better access management. ([Microsoft Learn][1])

## 1. Prerequisites

Install the following tools on your local machine:

### Azure CLI

Used to authenticate to Azure and retrieve AKS credentials.

```bash
az --version
```

Login:

```bash
az login
```

Verify your subscription:

```bash
az account show
```

If you have multiple subscriptions:

```bash
az account set --subscription "<subscription-name-or-id>"
```

### kubectl

Used to communicate with the Kubernetes API server.

```bash
kubectl version --client
```

### kubelogin

Required for Microsoft Entra ID authentication scenarios.

```bash
kubelogin --version
```

For current AKS versions, Azure CLI can manage `kubectl` and `kubelogin`; AKS Kubernetes 1.24+ uses the `kubelogin` exec-plugin format automatically for Entra-integrated clusters. ([Microsoft Learn][2])

---

# 2. Access AKS Without SSO

This means using the **local AKS administrator credentials** instead of your Microsoft Entra identity.

> This is generally intended for administrative/break-glass scenarios, not normal enterprise user access.

### Step 1: Login to Azure

```bash
az login
```

### Step 2: Get AKS admin credentials

```bash
az aks get-credentials \
  --resource-group <resource-group-name> \
  --name <aks-cluster-name> \
  --admin
```

Example:

```bash
az aks get-credentials \
  --resource-group prod-rg \
  --name production-aks \
  --admin
```

### Step 3: Verify access

```bash
kubectl get nodes
```

You should see something similar to:

```text
NAME                                STATUS   ROLES
aks-system-12345678-vmss000000     Ready    <none>
aks-user-12345678-vmss000000       Ready    <none>
```

### What does `--admin` do?

```bash
--admin
```

Gets the **local AKS cluster-admin credentials** and adds them to your kubeconfig. These credentials bypass Microsoft Entra authentication. ([Microsoft Learn][3])

So:

```text
az aks get-credentials --admin
              ↓
      Get admin kubeconfig
              ↓
       ~/.kube/config
              ↓
           kubectl
              ↓
          AKS cluster
```

---

# 3. Access AKS Using SSO / Microsoft Entra ID

For enterprise environments, this is the preferred approach.

### Step 1: Login using Azure CLI

```bash
az login
```

This authenticates you using your **Microsoft Entra ID account**.

### Step 2: Get your AKS user credentials

```bash
az aks get-credentials \
  --resource-group <resource-group-name> \
  --name <aks-cluster-name>
```

Example:

```bash
az aks get-credentials \
  --resource-group prod-rg \
  --name production-aks
```

Notice there is **no `--admin`**.

This retrieves the **user credentials** and merges the AKS context into your local kubeconfig. ([Microsoft Learn][2])

### Step 3: Authenticate with kubelogin

For Azure CLI-based authentication:

```bash
kubelogin convert-kubeconfig -l azurecli
```

This configures your kubeconfig to use the credentials from your existing Azure CLI login. ([Microsoft Learn][4])

### Step 4: Test access

```bash
kubectl get nodes
```

If your Entra identity has the required Kubernetes/Azure RBAC permissions, you'll be able to access the cluster.

---

# 4. What Happens Behind the Scenes?

### Without SSO

```text
az login
    ↓
az aks get-credentials --admin
    ↓
Admin credentials → ~/.kube/config
    ↓
kubectl
    ↓
AKS API Server
```

### With SSO

```text
az login
    ↓
Microsoft Entra ID
    ↓
az aks get-credentials
    ↓
User kubeconfig
    ↓
kubelogin
    ↓
Entra access token
    ↓
AKS API Server
```

The important difference is **who authenticates you**:

```text
--admin
   ↓
Local AKS admin credentials

Without --admin
   ↓
Microsoft Entra ID / SSO
```

---

# 5. Important Commands

| Command                                    | Purpose                                                    |
| ------------------------------------------ | ---------------------------------------------------------- |
| `az login`                                 | Login to Azure                                             |
| `az account show`                          | Show current Azure account/subscription                    |
| `az aks get-credentials`                   | Get AKS user credentials and update kubeconfig             |
| `az aks get-credentials --admin`           | Get local AKS admin credentials                            |
| `kubelogin convert-kubeconfig -l azurecli` | Configure kubeconfig to authenticate using Azure CLI/Entra |
| `kubectl get nodes`                        | Verify cluster access                                      |
| `kubectl get pods -A`                      | View pods across all namespaces                            |
| `kubectl config get-contexts`              | View available AKS contexts                                |
| `kubectl config use-context <context>`     | Switch between clusters                                    |

---

## 6. Production Best Practice

For an enterprise AKS environment:

```text
                    Microsoft Entra ID
                          │
                     SSO / MFA
                          │
                          ↓
                     kubelogin
                          │
                          ↓
                    AKS API Server
                          │
                    Azure RBAC /
                  Kubernetes RBAC
```

Use:

**Microsoft Entra ID + RBAC + SSO**

rather than distributing `--admin` credentials to engineers.

Keep local admin access primarily as a **break-glass mechanism** when Entra authentication is unavailable. Microsoft specifically documents local admin credentials as a fallback path. ([Microsoft Learn][2])

### Quick interview summary

> **`az aks get-credentials` gets the AKS cluster credentials and adds the cluster context to my local kubeconfig. Without `--admin`, I use my Microsoft Entra identity for SSO authentication. With `--admin`, I use the local AKS administrator credentials. In production, I prefer Entra ID with RBAC because it provides centralized enterprise identity and access control.** ([Microsoft Learn][2])

[Microsoft Learn — AKS authentication](https://learn.microsoft.com/en-us/azure/aks/concepts-cluster-authentication?utm_source=chatgpt.com)
[Microsoft Learn — Use kubelogin with AKS](https://learn.microsoft.com/th-th/azure/aks/kubelogin-authentication?view=azureml-api-2&utm_source=chatgpt.com)

[1]: https://learn.microsoft.com/en-us/azure/aks/concepts-cluster-authentication?utm_source=chatgpt.com "Cluster authentication concepts in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn"
[2]: https://learn.microsoft.com/en-us/azure/aks/entra-id-control-plane-authentication?utm_source=chatgpt.com "Enable Microsoft Entra ID Authentication for the Azure Kubernetes Service (AKS) Control Plane - Azure Kubernetes Service | Microsoft Learn"
[3]: https://learn.microsoft.com/en-us/%20azure/aks/enable-authentication-microsoft-entra-id?utm_source=chatgpt.com "Enable Microsoft Entra ID Authentication for the Azure Kubernetes Service (AKS) Control Plane - Azure Kubernetes Service | Microsoft Learn"
[4]: https://learn.microsoft.com/th-th/azure/aks/kubelogin-authentication?view=azureml-api-2&utm_source=chatgpt.com "Use kubelogin to authenticate in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn"
