module "vpc" {
    source = "./VPC"
    vpc_cidr = var.cidr_block
    name_prefix = "myapp"
    azs = slice(data.aws_availability_zones.available.names, 0, 2)
    public_subnet_cidr = var.public_subnet_cidr
    public_subnet_az = data.aws_availability_zones.available.names[0]
    private_subnet_cidr = var.private_subnet_cidr

    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Environment = "dev"
    }                      

