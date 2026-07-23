resource "aws_vpc" "main" {
    cidr_block       = var.primary_vpc_cidr
    instance_tenancy = "default"
    provider = aws.primary
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "primary_vpc-${var.primary}"
    }
}

resource "aws_vpc" "main" {
    cidr_block       = var.secondary_vpc_cidr_block
    instance_tenancy = "default"
    provider = aws.secondary
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "secondary_vpc-${var.secondary}"
    }
}
