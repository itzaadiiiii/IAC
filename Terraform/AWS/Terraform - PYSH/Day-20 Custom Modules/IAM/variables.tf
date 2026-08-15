variable "cluster_name" {
    description = "Name of the EKS cluster"
    type        = string
}

variable "tags" {
    description = "Tags to apply to the resources"
    type        = map(string)
    default     = {}
}

# Attach required policies to cluster role
resource "aws_iam_role_policy_attachment" "cluster_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_vpc_resource_controller" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
    role       = aws_iam_role.cluster.name
}

# Node Group IAM Role
resource "aws_iam_role" "node_group" {
    name_prefix = "${var.cluster_name}-node-"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
            Service = "ec2.amazonaws.com"
        }
        }]
    })

    tags = var.tags
}