#!/usr/bin/env bash
# =============================================================================
# One-time script to create the S3 bucket + DynamoDB table for Terraform state
# Run this from an account that has permission to create these resources
# (usually the shared-services or a management account)
# =============================================================================

set -euo pipefail

BUCKET_NAME="mycompany-terraform-state-prod"
DYNAMODB_TABLE="terraform-locks"
REGION="us-east-1"

echo "Creating S3 bucket: $BUCKET_NAME"
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION" 2>/dev/null || echo "Bucket may already exist"

echo "Enabling versioning..."
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled

echo "Enabling encryption..."
aws s3api put-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --server-side-encryption-configuration '{
    "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]
  }'

echo "Blocking public access..."
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo "Creating DynamoDB table for locking: $DYNAMODB_TABLE"
aws dynamodb create-table \
  --table-name "$DYNAMODB_TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION" 2>/dev/null || echo "Table may already exist"

echo ""
echo "✅ Backend resources ready!"
echo "   S3 Bucket      : $BUCKET_NAME"
echo "   DynamoDB Table : $DYNAMODB_TABLE"
echo "   Region         : $REGION"
