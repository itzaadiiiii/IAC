ecs-terraform/
├── main.tf                 # Root orchestration (calls modules)
├── variables.tf
├── outputs.tf
├── providers.tf
├── backend.tf              # S3 + DynamoDB (recommended)
├── terraform.tfvars.example
├── modules/
│   ├── vpc/                # VPC, subnets, endpoints
│   ├── alb/                # Application Load Balancer + Target Groups
│   ├── security/           # Security Groups
│   ├── ecs-cluster/        # ECS Cluster + Capacity Providers + Logs
│   ├── ecs-service/        # Task Definition + Service + IAM roles + Auto Scaling
│   └── iam/                # Shared IAM policies/roles (optional)
├── environments/           # Optional: dev/staging/prod (with terragrunt or tfvars)
│   └── prod/
│       └── terraform.tfvars
└── .terraform.lock.hcl