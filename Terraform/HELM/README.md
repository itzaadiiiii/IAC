The **HashiCorp Helm Provider** for Terraform **allows you to manage Kubernetes applications via Helm charts natively within your Terraform workflow**. It bridges the gap between infrastructure provisioning (like setting up an EKS or GKE cluster) and application deployment.

Here is a complete guide and boilerplate configuration to get started.

**1. Provider Configuration**

You must configure the Helm provider with the proper Kubernetes cluster credentials before deploying charts. You can pass static credentials, load a local `kubeconfig` file, or dynamically pull cluster info from an upstream cloud provider resource.

**hcl**

```
terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0" # Or v3.0+ depending on your version framework
    }
  }
}

# Example using a local kubeconfig file
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
```

Use code with caution.

---

**2. Deploying a Public Chart**

To deploy a chart from a public repository (e.g., Nginx, Prometheus, Cert-Manager), use the `helm_release` resource. [1, 2]

**hcl**

```
resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  repository       = "https://github.io"
  chart            = "ingress-nginx"
  version          = "4.10.0" # Always pin your chart versions
  namespace        = "ingress-basic"
  create_namespace = true

  # Pass custom values by using standard YAML format
  values = [
    <<-EOT
    controller:
      replicaCount: 2
      service:
        annotations:
          service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    EOT
  ]

  # Inline target setting if needed
  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }
}
```

Use code with caution.

---

**3. Deploying a Local Chart**

If your Helm chart is stored locally inside your git repository or project folder, change the `chart` argument to point directly to the directory path containing your `Chart.yaml`. [1]

**hcl**

```
resource "helm_release" "local_app" {
  name      = "my-custom-app"
  chart     = "./charts/my-web-app" # Path to your local chart directory
  namespace = "default"

  # Pass custom configuration values from a separate file
  values = [
    file("${path.module}/values/production.yaml")
  ]
}
```

Use code with caution.

---

**💡 Best Practices**

**Always Pin Chart Versions:** Never omit the `version` argument. Leaving it out pulls the latest available chart, which can break your environment during a random `terraform apply`.

- **Always Pin Chart Versions:** Never omit the `version` argument. Leaving it out pulls the latest available chart, which can break your environment during a random `terraform apply`.

**Handle Sensitive Data Securely:** For passwords, API keys, or tokens, use the `set_sensitive` block instead of raw strings inside the `values` argument. This masks the values in your Terraform CLI console output.

- **Handle Sensitive Data Securely:** For passwords, API keys, or tokens, use the `set_sensitive` block instead of raw strings inside the `values` argument. This masks the values in your Terraform CLI console output.

**Enable Rollbacks:** Consider setting `atomic = true` or `cleanup_on_fail = true` on critical `helm_release` resources so that Terraform automatically rolls back a deployment if Kubernetes pods fail to reach a healthy status.

- **Enable Rollbacks:** Consider setting `atomic = true` or `cleanup_on_fail = true` on critical `helm_release` resources so that Terraform automatically rolls back a deployment if Kubernetes pods fail to reach a healthy status.

### If you would like to tailor this configuration, let me know

What **cloud platform** or **Kubernetes cluster** (EKS, GKE, AKS, local) you are connecting to?

- What **cloud platform** or **Kubernetes cluster** (EKS, GKE, AKS, local) you are connecting to?

Which specific **Helm chart** you are trying to install?

- Which specific **Helm chart** you are trying to install?

If you need to map cloud-specific **IAM Roles (IRSA)** or resources into your Helm values?

- If you need to map cloud-specific **IAM Roles (IRSA)** or resources into your Helm values?
