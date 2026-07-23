resource "aws_vpc" "main" {
    cidr_block       = var.cidr_block
    instance_tenancy = "default"
    provider = aws.primary
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "main"
    }
}
