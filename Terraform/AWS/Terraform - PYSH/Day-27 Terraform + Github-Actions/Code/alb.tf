# 1. Define the Application Load Balancer
resource "aws_lb" "main" {
    name               = "main-application-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.alb_sg.id]
    subnets            = ["subnet-xxxxxxxxxxxxxxxxx", "subnet-yyyyyyyyyyyyyyyyy"] # Replace with your public subnet IDs

    enable_deletion_protection = false
}

# 2. Define the Target Group for backend routing
resource "aws_lb_target_group" "main" {
    name        = "main-alb-target-group"
    port        = 80
    protocol    = "HTTP"
    vpc_id      = "vpc-xxxxxxxxxxxxxxxxx" # Replace with your VPC ID
    target_type = "instance"               # Or "ip" if using ECS Fargate

    health_check {
        enabled             = true
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 30
        matcher             = "200"
    }
}

# 3. Define the HTTP Listener
resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.main.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.main.arn
    }
}