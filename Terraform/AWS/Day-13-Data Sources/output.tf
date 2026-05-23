output "vpc_id" {
  value = data.aws_vpc.default.id
}


output "subnet_cidr_blocks" {
  value = values(data.aws_subnet.default-subnet)[*].cidr_block
}


output "ami_id" {
  value = data.aws_ami.ami-mumbai.id
}

output "ami_name" {
  value = data.aws_ami.ami-mumbai.name
}

output "instance-public-ip" {
  value = aws_instance.my_instance.public_ip
}
