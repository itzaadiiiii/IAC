# 🚀 AWS Lambda EC2 Auto Scheduler using Terraform

> 🟢 **Automate EC2 Start/Stop Scheduling to Reduce AWS Costs using a Fully Serverless Infrastructure as Code (IaC) Solution**

---

# 📌 Real-World Production Problem Statement

Company **XYZ** has two Amazon EC2 instances used by developers for **Development**, **Testing**, and **QA** activities.

Although these instances are required **only during business hours**, they continue running **24×7**, including nights and weekends, resulting in **unnecessary AWS compute costs**.

The **Cloud Engineering Team** has been tasked with designing an automated, reliable, and production-ready solution that meets the following requirements:

### ✅ Requirements

* 🛑 Automatically **stop EC2 instances every Friday at 8:00 PM (IST)**
* ▶️ Automatically **start EC2 instances every Monday at 8:00 AM (IST)**
* 🤖 Eliminate all manual intervention
* 🔁 Ensure the solution is reliable, repeatable, and scalable
* 🏗️ Manage the entire infrastructure using **Infrastructure as Code (Terraform)**

---

# 💡 Proposed Solution

To address this requirement, we will build a **fully automated serverless scheduling solution** using native AWS services and Terraform.

### 🏛️ Architecture

```text
                ⏰ Amazon EventBridge
             (Scheduled Cron Rules)
                       │
                       ▼
        🐍 AWS Lambda (Python 3.12 + Boto3)
                       │
                       ▼
               ☁️ Amazon EC2 Instances
                (Start / Stop Operations)
```

---

# 🛠️ Technologies Used

| Technology                | Purpose                       |
| ------------------------- | ----------------------------- |
| 🏗️ Terraform             | Infrastructure as Code (IaC)  |
| ⚡ AWS Lambda              | Serverless compute            |
| 🐍 Python 3.12            | Lambda runtime                |
| 📦 Boto3                  | AWS SDK for Python            |
| ⏰ Amazon EventBridge      | Scheduled event execution     |
| 🔐 IAM Roles & Policies   | Secure permissions for Lambda |
| 🖥️ Amazon EC2            | Compute instances             |
| 📊 Amazon CloudWatch Logs | Monitoring & Troubleshooting  |

---

# ⚙️ Solution Workflow

```text
Terraform
    │
    ▼
Provision AWS Resources
    │
    ▼
Amazon EventBridge
(Scheduled Cron Trigger)
    │
    ▼
AWS Lambda
(Python + Boto3)
    │
    ▼
EC2 API
(Start / Stop Instances)
    │
    ▼
Amazon CloudWatch Logs
(Monitoring & Auditing)
```

### 📋 Step-by-Step Execution

1. 🏗️ Terraform provisions all required AWS resources.
2. ⏰ Amazon EventBridge triggers the Lambda function based on the configured schedule.
3. ⚡ Lambda receives the requested action (**Start** or **Stop**).
4. 🐍 Using **Boto3**, Lambda calls the EC2 API.
5. 🖥️ The specified EC2 instances are started or stopped automatically.
6. 📊 CloudWatch Logs capture execution details for monitoring, auditing, and troubleshooting.

---

# 🎯 Business Benefits

* 💰 Reduce unnecessary AWS infrastructure costs
* 🤖 Eliminate repetitive manual operations
* ⚡ Improve operational efficiency
* ☁️ Leverage a fully serverless architecture
* 🏗️ Manage infrastructure using Terraform (IaC)
* 🔄 Ensure repeatable and version-controlled deployments
* 📈 Improve governance and operational reliability

---

# ✅ Expected Outcome

After deployment:

🛑 **Every Friday at 8:00 PM (IST)**

* EC2 instances automatically stop.

▶️ **Every Monday at 8:00 AM (IST)**

* EC2 instances automatically start.

### 🎉 Final Result

* 💰 Lower AWS compute costs
* ⚙️ Zero manual intervention
* 🚀 Fully automated scheduling
* ☁️ Production-ready serverless solution
* 🏗️ Entire infrastructure managed through Terraform

---

# 📂 Deployment Commands

### 📦 Initialize Terraform

```bash
terraform init -backend-config=backend.config
```

### 🔍 Review Execution Plan

```bash
terraform plan -var-file=dev.tfvars
```

### 🚀 Deploy Infrastructure

```bash
terraform apply -var-file=dev.tfvars -auto-approve
```

### 🗑️ Destroy Infrastructure

```bash
terraform destroy -var-file=dev.tfvars -auto-approve
```

---

# 🎨 AWS Services Used

| AWS Service          | Purpose                   |
| -------------------- | ------------------------- |
| ⚡ AWS Lambda         | Execute automation logic  |
| ⏰ Amazon EventBridge | Schedule Lambda execution |
| 🖥️ Amazon EC2       | Target instances          |
| 🔐 IAM               | Secure permissions        |
| 📊 CloudWatch Logs   | Logging & Monitoring      |

---

> **✨ Result:** A fully automated, production-ready, serverless EC2 scheduling solution that optimizes AWS costs while following Infrastructure as Code (IaC) best practices.
