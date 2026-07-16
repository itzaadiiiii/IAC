# Create bucket for Terraform state
aws s3 mb s3://Terraform-Github-Actionsss --region us-east-1

# Enable versioning for state history
aws s3api put-bucket-versioning \
  --bucket Terraform-Github-Actionsss \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket staging-my-terraform-bucket-saydhw \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'
