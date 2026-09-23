# Get the existing AWS default VPC
data "aws_vpc" "default" {
    default = true
}

variable "vpc_id" {
    description = "The ID of the VPC to import the security group into"
    type        = string
    default     = data.aws_vpc.default.id
    }

# Existing Security Group
resource "aws_security_group" "terra-import-sg" {
    name        = "terra-import-sg"
    description = "Security group managed by Terraform"
    vpc_id      = data.aws_vpc.default.id

    # SSH - Port 22
    ingress {
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # HTTP - Port 80
    ingress {
        description = "HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # HTTPS - Port 443
    ingress {
        description = "HTTPS"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow all outbound traffic
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "terra-import-sg"
    }
    }
# # For better coding standards, you can use dynamic blocks to define the ingress and egress rules. This allows you to easily manage multiple rules without duplicating code. Here's an example of how you can use dynamic blocks for the ingress rules:
# variable "ingress_ports" {
#     default = [22, 80, 443]
# }

# resource "aws_security_group" "terra_import_sg" {
#     name   = "terra-import-sg"
#     vpc_id = data.aws_vpc.default.id

#     dynamic "ingress" {
#         for_each = var.ingress_ports

#         content {
#         description = "Allow port ${ingress.value}"
#         from_port   = ingress.value
#         to_port     = ingress.value
#         protocol    = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
#         }
#     }

#     egress {
#         from_port   = 0
#         to_port     = 0
#         protocol    = "-1"
#         cidr_blocks = ["0.0.0.0/0"]
#     }
# }

#Option 2 — Map (better for real projects)

#If you want different descriptions or protocols:

variable "ingress_rules" {
    default = {
        ssh = {
        port        = 22
        description = "SSH"
        }

        http = {
        port        = 80
        description = "HTTP"
        }

        https = {
        port        = 443
        description = "HTTPS"
        }
    }
}

resource "aws_security_group" "terra_import_sg" {
    name   = "terra-import-sg"
    vpc_id = data.aws_vpc.default.id

    dynamic "ingress" {
        for_each = var.ingress_rules

        content {
        description = ingress.value.description
        from_port   = ingress.value.port
        to_port     = ingress.value.port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        }
    }
}

#Interview answer:

#"Yes, instead of repeating ingress blocks, we can use Terraform's dynamic block with for_each. For simple identical rules, a list of ports is enough; for enterprise configurations where each rule has different attributes, I prefer a map/object structure."

#One important distinction: you can't directly do for_each on an ingress {} block. You use dynamic "ingress" to generate multiple nested ingress blocks.