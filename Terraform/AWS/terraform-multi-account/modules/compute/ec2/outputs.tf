output "instance_ids" {
  value = aws_instance.this[*].id
}

output "private_ips" {
  value = aws_instance.this[*].private_ip
}

output "security_group_id" {
  value = aws_security_group.ec2.id
}
