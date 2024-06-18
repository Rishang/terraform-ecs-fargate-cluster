locals {}

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }
}


resource "aws_ecr_repository" "this" {
  for_each = var.services
  name     = "${var.cluster_name}-${each.value.name}"
}


resource "aws_cloudwatch_log_group" "app" {
  for_each          = var.services
  name              = "/ecs/${aws_ecs_cluster.this.name}/${local.service_name}"
  retention_in_days = 30
}

