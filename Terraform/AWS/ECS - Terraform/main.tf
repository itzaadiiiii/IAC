    module "vpc" {
    source = "./modules/vpc"

    name       = "${var.project_name}-vpc"
    cidr       = var.vpc_cidr
    azs        = var.azs
    environment = var.environment
    }

    module "alb" {
    source = "./modules/alb"

    name               = "${var.project_name}-alb"
    vpc_id             = module.vpc.vpc_id
    public_subnets     = module.vpc.public_subnets
    security_group_ids = [module.security.alb_sg_id]
    certificate_arn    = var.certificate_arn # optional
    environment        = var.environment
    }

    module "security" {
    source = "./modules/security"

    vpc_id             = module.vpc.vpc_id
    environment        = var.environment
    alb_sg_ingress_cidr = ["0.0.0.0/0"] # tighten in prod
    }

    module "ecs_cluster" {
    source = "./modules/ecs-cluster"

    cluster_name = var.ecs_cluster_name
    environment  = var.environment
    }

    module "ecs_service" {
    source = "./modules/ecs-service"

    cluster_id          = module.ecs_cluster.cluster_id
    service_name        = "${var.project_name}-service"
    vpc_id              = module.vpc.vpc_id
    private_subnets     = module.vpc.private_subnets
    security_group_ids  = [module.security.ecs_tasks_sg_id]
    target_group_arn    = module.alb.target_group_arn
    container_image     = var.container_image
    container_port      = var.container_port
    cpu                 = var.cpu
    memory              = var.memory
    desired_count       = var.desired_count
    execution_role_arn  = module.ecs_service.execution_role_arn # self-managed or passed
    environment         = var.environment

    depends_on = [module.alb]
    }