# Here we created the Azure Container Instance via UI and downlaoded a Template

# Q. Here how you can use it?

What you exported is a **Bicep template**. It is **not automatically stored in Azure** as reusable Infrastructure as Code (IaC). Azure simply generates it for you.

## Where is it saved?

When you click **Export Template**, Azure gives you options like:

* **Download** → Downloads `main.bicep` (or ARM JSON) to your local machine.
* **Save to GitHub** (if configured).
* **Copy** the template.

Azure itself **does not save it permanently** for you.

In real projects, we store it in Git.

Example:

```text
infra/

├── bicep/
│   ├── main.bicep
│   ├── parameters/
│   │   ├── dev.bicepparam
│   │   ├── qa.bicepparam
│   │   └── prod.bicepparam
│   └── modules/
```

---

# How do you reuse it?

Suppose you save:

```text
main.bicep
```

Create a parameter file:

```bicep
using './main.bicep'

param containerGroups_hello_world_workspaceKey = 'xxxxxxxx'
param containerGroups_hello_world_name = 'hello-world'
```

Then deploy it:

```bash
az deployment group create \
  --resource-group my-rg \
  --template-file main.bicep \
  --parameters dev.bicepparam
```

Azure reads the template and creates the resources.

---

# Can I redeploy it?

**Yes.**

That's the whole purpose of Infrastructure as Code.

Example:

```bash
az deployment group create \
--resource-group dev-rg \
--template-file main.bicep \
--parameters dev.bicepparam
```

Tomorrow, if someone deletes the container:

```text
ACI Deleted
```

Run the same command again:

```bash
az deployment group create ...
```

Azure recreates it.

---

# Can I create another environment?

Absolutely.

Example:

```
main.bicep
```

Deploy to Dev:

```bash
az deployment group create \
--resource-group dev-rg \
--template-file main.bicep \
--parameters containerGroups_hello_world_name=dev-hello
```

Deploy to QA:

```bash
az deployment group create \
--resource-group qa-rg \
--template-file main.bicep \
--parameters containerGroups_hello_world_name=qa-hello
```

Same template, different parameters.

---

# One thing you should change

Your exported template contains:

```bicep
ip: '128.203.82.106'
```

This is **not recommended**.

A public IP is usually assigned dynamically. Remove it and let Azure allocate a new one.

Similarly, don't hardcode:

```bicep
workspaceId: '597852f1-41cf-4b4c-bbb0-953cd7a0897e'
```

Make it a parameter:

```bicep
param workspaceId string
```

This makes the template reusable across environments.

---

## Interview Answer (30 sec)

> "The exported Bicep template is typically stored in a Git repository as Infrastructure as Code. We parameterize environment-specific values such as resource names, Log Analytics Workspace IDs, and locations. Whenever we need to recreate or deploy the infrastructure, we run `az deployment group create` with the Bicep template and the appropriate parameter file. This allows us to provision consistent Dev, QA, or Production environments repeatedly using the same code."
