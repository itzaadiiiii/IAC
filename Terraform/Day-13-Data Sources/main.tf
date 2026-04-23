
data "aws_vpc" "default" {
    filter {
        name = "tag:Name"
        values = ["default"]
    }
}

data "aws_subnets" "default-subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "default-subnet" {
  for_each = toset(data.aws_subnets.default-subnets.ids)
  id       = each.value
}


data "aws_ami" "ami-mumbai" {
  # executable_users = ["self"]
  most_recent      = true
  # name_regex       = "^myami-[0-9]{3}"
  owners           = ["amazon"]

  filter {
    name   = "image-id"
    values = ["ami-0f559c3642608c138"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "my_instance" {
  ami           = data.aws_ami.ami-mumbai.id
  instance_type = "t2.micro"
  subnet_id = values(data.aws_subnet.default-subnet)[0].id
  region        = data.aws_vpc.default.region
}
