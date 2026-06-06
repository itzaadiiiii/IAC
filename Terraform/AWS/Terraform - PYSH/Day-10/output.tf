output "vpc_id" {
  value = aws_vpc.main.id
}

output "web_server_id" {
  value = aws_instance.web_server.id
}