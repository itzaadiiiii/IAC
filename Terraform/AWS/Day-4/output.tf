output "Instance_Public_IP" {
  description = "The public IP of the instance"
  value = aws_instance.firstinstance.public_ip
}