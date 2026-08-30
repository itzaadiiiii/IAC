# Create bucket for backend state storage
resource "aws_s3_bucket" "backend_bucket" {
    bucket = "${var.project_name}-backend-buckettt"

    lifecycle {
        prevent_destroy = true
    }
}
