locals {
  cluster_name = aws_ecs_cluster.this.name
  region = data.aws_region.current.name
}

data "aws_region" "current" {}

resource "aws_ecs_cluster" "this" {
  name = "${var.environment}-${var.cluster_name}"

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "app" {
  cluster_name = local.cluster_name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 10
    capacity_provider = "FARGATE"
  }
}

# ecs task execution role 
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${local.cluster_name}-${local.region}-ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_AmazonECSTaskExecutionRolePolicy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# ecs task role
resource "aws_iam_role" "ecsTaskRole" {
  for_each = var.services

  name = "${local.cluster_name}-${each.key}-${local.region}-ECSRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# ecs task policy
resource "aws_iam_policy" "ecsTaskPolicy" {
  for_each    = var.services
  name        = "${local.cluster_name}-${each.key}-${local.region}-ECSPolicy"
  description = "ECS Task Policy for ${each.key}"
  policy      = jsonencode(lookup(each.value, "task_policy", {
      "Version": "2012-10-17",
      "Statement": [
        {
            "Effect": "Allow",
            "Action": "none:null",
            "Resource": "*",

        }
      ]
    })
  )
}

# ecs task policy attachment
resource "aws_iam_role_policy_attachment" "ecsTaskPolicyAttachment" {
  for_each = var.services
  role       = aws_iam_role.ecsTaskRole[each.key].name
  policy_arn = aws_iam_policy.ecsTaskPolicy[each.key].arn
}

# service discovery
resource "aws_service_discovery_private_dns_namespace" "service" {
  count = var.enable_discovery ? 1 : 0
  name  = var.cluster_name
  vpc   = var.vpc_id
}



resource "aws_ecr_repository" "this" {
  for_each = var.services
  name     = "${local.cluster_name}-${each.key}"
}


resource "aws_cloudwatch_log_group" "this" {
  for_each          = var.services
  name              = "/ecs/${local.cluster_name}/${each.key}"
  retention_in_days = var.cloudwatch_log_retention_days
}



# things to be created
# ecs service (memory scaling) >> TargetGroup >> Alb HTTPS rule >> Route53 >> app.example.com
module "fargate_task_definition" {
  for_each = var.services

  source  = "Rishang/ecs-task-definition/aws"
  version = "2.1.9"

  family                   = "${local.cluster_name}-${each.value.name}"
  image                    = aws_ecr_repository.this[each.key].repository_url
  memory                   = lookup(each.value, "memory", 512)
  cpu                      = lookup(each.value, "cpu", 256)
  name                     = each.value.name
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecsTaskRole[each.key].arn
  network_mode             = "awsvpc"
  environment              = lookup(each.value, "env_vars", {})
  portMappings = [
    {
      containerPort = each.value.container_port
    },
  ]
}

module "fargate" {
  for_each = var.services
  source   = "Rishang/fargate/aws"
  version  = "1.4.3"

  EnvironmentName = var.environment

  # ecs fargate
  cluster             = aws_ecs_cluster.this.name
  service             = each.value.name
  container_name      = each.value.name
  container_port      = each.value.container_port
  task_definition_arn = module.fargate_task_definition[each.key].arn


  # keep 1 FARGATE
  capacity_provider_strategy = lookup(
    each.value, "capacity_provider_strategy", [
      {
        base              = 1
        capacity_provider = "FARGATE"
        weight            = 1
      },
      {
        base              = 0
        capacity_provider = "FARGATE_SPOT"
        weight            = 0
      },
    ]
  )

  # networking
  assign_public_ip = each.value.assign_public_ip # optional
  vpc_id           = var.vpc_id
  subnets          = var.subnets
  security_groups  = var.security_groups

  # load balancer (optional)
  point_to_lb        = lookup(each.value, "point_to_lb", false)        # optional
  listener_arn_https = lookup(each.value, "listener_arn_https", "")    # optional
  path_pattern       = lookup(each.value, "path_pattern", ["/", "/*"]) # optional

  subdomain = lookup(each.value, "subdomain", "") # optional

  # route53 (optional)
  point_to_r53 = lookup(each.value, "point_to_r53", false) # optional

  # autoscale (optional)
  create_autoscale_target = lookup(each.value, "create_autoscale_target", false) # optional
  lb_scale_target         = lookup(each.value, "lb_scale_target", -1)            # optional
  cpu_scale_target        = lookup(each.value, "cpu_scale_target", -1)           # optional
  memory_scale_target     = lookup(each.value, "memory_scale_target", -1)        # optional

  scale_in_cooldown  = lookup(each.value, "scale_in_cooldown", 300)  # optional
  scale_out_cooldown = lookup(each.value, "scale_out_cooldown", 300) # optional
  scale_min_capacity = lookup(each.value, "scale_min_capacity", 1)   # optional
  scale_max_capacity = lookup(each.value, "scale_max_capacity", 10)  # optional

  # scheduled scaling (optional)
  scaling_schedule = lookup(each.value, "scaling_schedule", []) # optional
  # scaling_schedule = [
  #   {
  #     # Scale count to zero every night at 19:00
  #     schedule     = "cron(0 19 * * ? *)"
  #     min_capacity = 0
  #     max_capacity = 0
  #   },
  #   {
  #     # Scale count to 3 every morning at 7:00
  #     schedule     = "cron(0 7 * * ? *)"
  #     min_capacity = 3
  #     max_capacity = 3
  #   }
  # ]

  # service discovery (optional)
  enable_discovery = var.enable_discovery
  namespace_id     = var.enable_discovery ? aws_service_discovery_private_dns_namespace.service[0].id : ""

  tags = {
    Name         = each.value.name
    Environment  = var.environment
    cluster_name = aws_ecs_cluster.this.name
  }
}
