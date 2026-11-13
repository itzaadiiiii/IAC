# Terraform Multi-Account Setup (Terragrunt + GitHub Actions)

Complete, production-style example for managing **5 AWS accounts** using Terraform + Terragrunt.

---

## 1. Account Strategy (Very Important)

We use **separate AWS accounts** for different environments. This is the recommended AWS best practice.

| Account            | Purpose                              | Example Account ID |
|--------------------|--------------------------------------|--------------------|
| shared-services    | Central networking, IAM, logging, security tools | 111111111111      |
| prod               | Production workloads                 | 222222222222      |
| staging            | Pre-production / UAT                 | 333333333333      |
| dev                | Development                          | 444444444444      |
| sandbox            | Experiments / breakable              | 555555555555      |

**Why separate accounts?**
- Strong isolation (security + blast radius)
- Clear billing separation
- Different IAM permission boundaries
- Easier compliance (prod can have stricter controls)

**Do we put stage/prod/dev in the same account?**  
→ No. Separate accounts is the modern recommended way (especially with AWS Control Tower / AFT).

---

## 2. High-Level Repo Structure

```text
terraform-multi-account/
├── modules/                          # Reusable Terraform modules
│   ├── network/
│   ├── compute/
│   │   ├── eks/
│   │   ├── ecs/
│   │   ├── ec2/
│   │   └── lambda/
│   ├── storage/                      # S3
│   ├── dynamodb/
│   ├── rds-mysql/
│   ├── elasticache/
│   ├── security/
│   └── observability/
│
├── live/                             # Actual deployments (one folder per account)
│   ├── shared-services/
│   │   ├── account.hcl
│   │   └── us-east-1/
│   │       ├── network/
│   │       └── security/
│   ├── prod/
│   │   ├── account.hcl
│   │   └── us-east-1/
│   │       ├── network/
│   │       ├── compute/
│   │       ├── data/                 # RDS + DynamoDB + ElastiCache + S3
│   │       └── app/
│   ├── staging/
│   ├── dev/
│   └── sandbox/
│
├── terragrunt.hcl                    # Root config (backend + provider generation)
├── .github/workflows/                # CI/CD
└── scripts/
```

---

## 3. State File Strategy

- **One state file per logical stack** (network, compute, data, etc.)
- Not one giant state per account
- Not one state per resource

Example state keys in S3:
```
live/prod/us-east-1/network/terraform.tfstate
live/prod/us-east-1/compute/terraform.tfstate
live/staging/us-east-1/network/terraform.tfstate
```

This keeps plans fast and blast radius small.

---

## 4. How Code is Deployed to a Particular Account

### Example: Launch `m6i.large` EC2 in **Staging** account

1. Developer changes code in:
   ```
   live/staging/us-east-1/compute/terragrunt.hcl
   ```
   or in the EC2 module inputs.

2. Pushes to GitHub (`main` or a feature branch).

3. GitHub Actions starts.

4. Workflow detects the changed path → knows it belongs to **staging** account.

5. It assumes the correct IAM role:
   ```hcl
   arn:aws:iam::333333333333:role/TerraformExecutionRole   # Staging account
   ```

6. Runs `terragrunt plan` → then `terragrunt apply` (after approval for non-dev).

7. Resources are created **only** in the Staging account.

**Key point:** The folder path + `account.hcl` decide the target account.  
CI/CD never hardcodes account IDs in the workflow for each job — Terragrunt injects the correct role automatically.

---

## 5. How CI/CD Picks the Right IAM Role

### Mechanism

1. Every account folder has an `account.hcl`:
   ```hcl
   locals {
     account_id = "333333333333"   # Staging
   }
   ```

2. Root `terragrunt.hcl` reads it and generates `provider.tf` with:
   ```hcl
   assume_role {
     role_arn = "arn:aws:iam::${local.account_id}:role/TerraformExecutionRole"
   }
   ```

3. GitHub Actions authenticates to AWS using **OIDC** (recommended) or access keys that have permission to `sts:AssumeRole` into the target account roles.

4. When Terragrunt runs, Terraform automatically assumes the role for that account.

### Required IAM Setup (one-time)

In **each** account (prod, staging, dev...), create:

```hcl
Resource: aws_iam_role.terraform_execution
AssumeRolePolicy: Allow the CI role (from shared or from GitHub OIDC) to assume it.
Permissions: PowerUserAccess or custom least-privilege policy.
```

---

## 6. Execution Flow (Manual + Pipeline)

### Manual
```bash
cd live/staging/us-east-1/compute
terragrunt init
terragrunt plan
terragrunt apply
```

### Pipeline (GitHub Actions)
1. On push / PR → Run `terragrunt plan` for changed stacks
2. Post plan summary to Slack + PR comment
3. On merge to `main` (or manual approval):
   - Apply the changes
   - If apply fails → automatic rollback (using previous state)
   - Send Slack + Email notification (success / failure)

---

## 7. Real Resources We Provision (Commented List)

In a real environment you would typically provision:

**Network**
- VPC, Public/Private/DB subnets
- Internet Gateway, NAT Gateways
- Route tables, NACLs
- VPC Endpoints (S3, ECR, Logs, STS...)
- Transit Gateway attachment (to shared-services)
- VPC Flow Logs

**Compute**
- EKS cluster + node groups (or Fargate)
- ECS Cluster + Services + Task Definitions
- EC2 instances (m6i.large, etc.) + ASG
- Lambda functions + layers + event sources

**Data / Storage**
- S3 buckets (with versioning, encryption, lifecycle)
- DynamoDB tables (on-demand or provisioned)
- RDS MySQL (Multi-AZ, read replicas, parameter groups)
- ElastiCache (Redis / Memcached)
- EFS (optional)

**Security**
- Security Groups
- KMS keys
- IAM roles & policies
- AWS WAF, Shield (optional)
- GuardDuty, Security Hub (usually in shared-services)

**Observability**
- CloudWatch Log Groups
- CloudWatch Alarms
- SNS topics
- (Optional) Prometheus / Grafana / OpenTelemetry

---

## 8. Quick Start

```bash
# 1. Clone
git clone <this-repo>
cd terraform-multi-account

# 2. Install tools
# - Terraform >= 1.5
# - Terragrunt >= 0.55
# - AWS CLI v2

# 3. Configure AWS credentials that can assume roles into the 5 accounts

# 4. Create backend resources (S3 + DynamoDB) - run once
cd scripts
./create-backend.sh

# 5. Deploy shared-services first
cd ../live/shared-services/us-east-1/network
terragrunt apply

# 6. Then deploy other accounts
cd ../../../staging/us-east-1/network
terragrunt apply
```

---

## 9. GitHub Actions Features

- Detects which stacks changed
- Runs `terragrunt plan` on PRs
- Requires manual approval for `staging` and `prod`
- Auto-applies `dev` and `sandbox`
- On apply failure → attempts rollback
- Sends notifications to Slack + Email

---

## 10. Important Notes

- Modules are written simply for learning. In real life, make them more complete and put them in a **separate versioned repository**.
- Replace dummy Account IDs with real ones.
- Replace Slack webhook and email secrets in GitHub Secrets.
- Use AWS OIDC (recommended) instead of long-lived access keys.

---

**Author:** Platform Team Example  
**Last Updated:** 2026-11-13
