# Azure Terraform Authentication Setup

This document explains how to create an Azure Service Principal for Terraform and configure the required environment variables for Azure authentication.

## Prerequisites

* Azure Subscription
* Permissions to create App Registrations in Azure Entra ID
* Permissions to assign IAM roles within the Azure Subscription

---

## Required Environment Variables

Terraform authenticates to Azure using the following environment variables:

```bash
export ARM_CLIENT_ID="<your-client-id>"
export ARM_CLIENT_SECRET="<your-client-secret>"
export ARM_TENANT_ID="<your-tenant-id>"
export ARM_SUBSCRIPTION_ID="<your-subscription-id>"
```

| Variable              | Description                                            |
| --------------------- | ------------------------------------------------------ |
| `ARM_CLIENT_ID`       | Application (Client) ID of the App Registration        |
| `ARM_CLIENT_SECRET`   | Client Secret Value generated for the App Registration |
| `ARM_TENANT_ID`       | Azure Entra ID Tenant ID                               |
| `ARM_SUBSCRIPTION_ID` | Azure Subscription ID                                  |

---

## Step 1: Create an App Registration

1. Sign in to the Azure Portal.

2. Navigate to:

   ```text
   Azure Portal → Azure Entra ID → App Registrations → New Registration
   ```

3. Enter a name for the application, for example:

   ```text
   terraform-iac
   ```

4. Click **Register**.

After registration, note the following values:

* **Application (Client) ID** → `ARM_CLIENT_ID`
* **Directory (Tenant) ID** → `ARM_TENANT_ID`

---

## Step 2: Assign Subscription Permissions

1. Navigate to:

   ```text
   Azure Portal → Subscriptions
   ```

2. Select the target subscription.

3. Go to:

   ```text
   Access Control (IAM) → Add Role Assignment
   ```

4. Configure the role assignment:

   * Role: **Contributor**
   * Assign access to: **User, Group, or Service Principal**
   * Select Members: Search for the App Registration created earlier (`terraform-iac`)

5. Review and assign the role.

---

## Step 3: Obtain Subscription ID

1. Navigate to:

   ```text
   Azure Portal → Subscriptions
   ```

2. Select the target subscription.

3. Copy the:

   ```text
   Subscription ID
   ```

4. Use this value as:

   ```bash
   ARM_SUBSCRIPTION_ID
   ```

---

## Step 4: Create a Client Secret

1. Navigate to:

   ```text
   Azure Portal → Azure Entra ID → App Registrations → terraform-iac
   ```

2. Open:

   ```text
   Certificates & Secrets → New Client Secret
   ```

3. Configure:

   * Description: Terraform Secret
   * Expiration: 90 Days (or as per organization policy)

4. Click **Add**.

5. Immediately copy the **Secret Value**.

> **Important:** Use the **Secret Value**, not the Secret ID.

This value becomes:

```bash
ARM_CLIENT_SECRET
```

---

## Step 5: Export Environment Variables

Configure the credentials in your shell:

```bash
export ARM_CLIENT_ID="<your-client-id>"
export ARM_CLIENT_SECRET="<your-client-secret>"
export ARM_TENANT_ID="<your-tenant-id>"
export ARM_SUBSCRIPTION_ID="<your-subscription-id>"
```

Verify the variables:

```bash
echo $ARM_CLIENT_ID
echo $ARM_TENANT_ID
echo $ARM_SUBSCRIPTION_ID
```

---

## Optional: Persist Variables in Bash

Add the exports to your shell profile:

```bash
vi ~/.bashrc
```

Append:

```bash
export ARM_CLIENT_ID="<your-client-id>"
export ARM_CLIENT_SECRET="<your-client-secret>"
export ARM_TENANT_ID="<your-tenant-id>"
export ARM_SUBSCRIPTION_ID="<your-subscription-id>"
```

Reload:

```bash
source ~/.bashrc
```

---

## Verify Terraform Authentication

Run:

```bash
terraform init
terraform plan
```

If authentication is configured correctly, Terraform will successfully connect to the Azure subscription using the Service Principal credentials.
