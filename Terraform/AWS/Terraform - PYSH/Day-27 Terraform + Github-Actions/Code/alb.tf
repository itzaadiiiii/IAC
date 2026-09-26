# 1. Define the Application Load Balancer
resource "aws_lb" "main" {
    name               = "main-application-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.alb_sg.id]
    subnets            = ["subnet-xxxxxxxxxxxxxxxxx", "subnet-yyyyyyyyyyyyyyyyy"] # Replace with your public subnet IDs

    enable_deletion_protection = false

}