# This config creates an ECS cluster and Fargate service in the default VPC of the
# region specified in your environment variables. It was more or less copied from
# the examples in the module below: 
# https://registry.terraform.io/modules/umotif-public/ecs-fargate/aws/latest

###################################################################################
# The two methods below are examples of how you could share the values of created
# resources outside of the context of the container task that was used to create
# your resources: 

output "ecs_service_arn" {
  value = module.ecs-fargate.service_arn
}

resource "aws_ssm_parameter" "ecs_service_arn" {
  name  = "/release/${local.unique_prefix}/ecs_service_arn"
  type  = "String"
  value = module.ecs-fargate.service_arn
}

##################################################################################

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

#####
# ALB
#####
module "alb" {
  source  = "umotif-public/alb/aws"
  version = "~> 2.0"

  name_prefix        = "release-ecs-fargate-demo"
  load_balancer_type = "application"
  internal           = false
  vpc_id             = data.aws_vpc.default.id
  subnets            = data.aws_subnets.all.ids
}

resource "aws_lb_listener" "alb_80" {
  load_balancer_arn = module.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = module.ecs-fargate.target_group_arn[0]
  }
}

#####
# Security Group Config
#####
resource "aws_security_group_rule" "alb_ingress_80" {
  security_group_id = module.alb.security_group_id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "task_ingress_80" {
  security_group_id        = module.ecs-fargate.service_sg_id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  source_security_group_id = module.alb.security_group_id
}

resource "aws_ecs_cluster" "cluster" {
  name = "release-terraform-demo"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = ["FARGATE_SPOT", "FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
  }
}

module "ecs-fargate" {
  source = "umotif-public/ecs-fargate/aws"
  version = "~> 6.1.0"

  name_prefix        = "release-ecs-example"
  vpc_id             = data.aws_vpc.default.id
  private_subnet_ids = data.aws_subnets.all.ids
  cluster_id         = aws_ecs_cluster.cluster.id

  task_container_image   = "marcincuber/2048-game:latest"
  task_definition_cpu    = 256
  task_definition_memory = 512

  task_container_port             = 80
  task_container_assign_public_ip = true

  load_balanced =  true
  
  target_groups = [
    {
      target_group_name = "release-ecs-demo-tg"
      container_port    = 80
    }
  ]

  health_check = {
    port = "traffic-port"
    path = "/"
  }
}