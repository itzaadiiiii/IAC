# S3 version cleanup – use Terraform instead of Lambda

# For your requirement to retain only the five latest noncurrent versions, I recommend native S3 Lifecycle.
resource "aws_s3_bucket_lifecycle_configuration" "version_cleanup" {

  bucket = aws_s3_bucket.documents.id

  rule {

    id = "retain-latest-five-versions"

    status = "Enabled"

    filter {}

    noncurrent_version_expiration {

      # Retain five newer noncurrent versions.
      newer_noncurrent_versions = 5

      # Older eligible versions must also be at least 30 days old.
      noncurrent_days = 30

    }

  }

}


# This is better than running a custom Lambda every week because S3 manages the cleanup itself.

# Important: Validate retention requirements before applying this to financial, audit or customer records. Object Lock and retention policies must take precedence.
