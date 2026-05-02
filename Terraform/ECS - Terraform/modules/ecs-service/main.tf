    # Task Execution Role
    resource "aws_iam_role" "execution_role" {
    name = "${var.service_name}-execution-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
        }]
    })
    }

    resource "aws_iam_role_policy_attachment" "execution" {
    role       = aws_iam_role.execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    }

    # Task Definition
    resource "aws_ecs_task_definition" "main" {
    family                   = var.service_name
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = var.cpu
    memory                   = var.memory
    execution_role_arn       = aws_iam_role.execution_role.arn
    task_role_arn            = aws_iam_role.task_role.arn # optional extra permissions

    container_definitions = jsonencode([{
        name      = var.service_name
        image     = var.container_image
        cpu       = var.cpu
        memory    = var.memory
        essential = true
        portMappings = [{
        containerPort = var.container_port
        hostPort      = var.container_port
        protocol      = "tcp"
        }]
        logConfiguration = {
        logDriver = "awslogs"
        options = {
            "awslogs-group"         = "/ecs/${var.cluster_name}" # or pass log group
            "awslogs-region"        = data.aws_region.current.name
            "awslogs-stream-prefix" = var.service_name
        }
        }
    }])
    }

    # ECS Service
    resource "aws_ecs_service" "main" {
    name            = var.service_name
    cluster         = var.cluster_id
    task_definition = aws_ecs_task_definition.main.arn
    desired_count   = var.desired_count
    launch_type     = "FARGATE"

    network_configuration {
        subnets          = var.private_subnets
        security_groups  = var.security_group_ids
        assign_public_ip = false
    }

    load_balancer {
        target_group_arn = var.target_group_arn
        container_name   = var.service_name
        container_port   = var.container_port
    }

    deployment_circuit_breaker {
        enable   = true
        rollback = true
    }

    lifecycle {
        ignore_changes = [task_definition] # for blue/green or external updates
    }
    }

    # Optional: Auto Scaling
    resource "aws_appautoscaling_target" "this" {
    max_capacity       = 10
    min_capacity       = 2
    resource_id        = "service/${var.cluster_id}/${aws_ecs_service.main.name}"
    scalable_dimension = "ecs:service:DesiredCount"
    service_namespace  = "ecs"
    }