# Custom EKS Module

# KMS Key for cluster encryption
resource "aws_kms_key" "eks" {
    description             = "KMS key for EKS cluster ${var.cluster_name} encryption"
    deletion_window_in_days = 7
    enable_key_rotation     = true

    tags = merge(
        var.tags,
        {
        Name = "${var.cluster_name}-eks-kms"
        }
    )
}