# Add VPC resource
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name = merge(var.tags, 
        {
            Name = "${var.name_prefix}-vpc"
        })
    }
}

#Add Internet Gateway
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${var.name_prefix}-igw"
    }
}

# Add Public Subnet
resource "aws_subnet" "public" {    
    vpc_id            = aws_vpc.main.id
    cidr_block        = var.public_subnet_cidr
    availability_zone = var.public_subnet_az

    tags = {
        Name = "${var.name_prefix}-public-subnet"
    }
}

