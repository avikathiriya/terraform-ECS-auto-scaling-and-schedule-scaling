
module "ecs" {
  source = "./modules/ECS"

  ecs_cluster_name   = "${var.app_name}-cluster"
  container_name     = "avi-container"
  container_image    = "829188654694.dkr.ecr.us-east-1.amazonaws.com/avis-ecs-app-ecr-repo"
  service_name       = "avi-ecs-service"
  desired_count      = 1
  container_port     = 8000
  cpu                = 256
  memory             = 512
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.sg.ecs_security_group_id]
  assign_public_ip   = false

  target_group_arn = aws_lb_target_group.ecs_tg.arn


  depends_on = [
    aws_lb_listener.ecs_http
  ]
}

module "sg" {
  source = "./modules/SG"

  vpc_id                = module.vpc.vpc_id
  sg_name               = "avis-ECS-app-sg"
  sg_description        = "Security group for ECS"
  app_port              = 8000
  alb_security_group_id = aws_security_group.alb_sg.id
}

module "vpc" {
  source = "./modules/VPC"

  vpc_name       = "${var.app_name}-vpc"
  vpc_cidr_block = "10.0.0.0/16"

  availability_zones = [
    "us-east-1a",
    "us-east-1b"
  ]

  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnet_cidrs = [
    "10.0.10.0/24",
    "10.0.11.0/24"
  ]
}