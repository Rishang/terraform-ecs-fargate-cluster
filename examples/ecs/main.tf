locals {
  EnvironmentName = "test"
  cluster_name    = "app"
}

# ------------------------ NERWORK -------------------------------
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ------------------------ SECURITY -------------------------------

resource "aws_security_group" "ecs_sg" {
  name        = "allow_tls for ecs fargate"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "all traffic allowed as containers will only allow exposed port"
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ecs_sg"
  }
}

# ------------------------ ECS ------------------------------------


module "fargate" {
  source = "../../"

  environment = local.EnvironmentName

  # fargate
  cluster_name = local.cluster_name
  vpc_id       = data.aws_vpc.default.id
  subnets      = data.aws_subnets.default.ids
  services = {
    "whoami" = {
      name             = "whoami"
      container_port   = 80
      memory           = 512
      cpu              = 256
      assign_public_ip = true

      # keep 1 FARGATE and 5 FARGATE_SPOT
      capacity_provider_strategy = [
        {
          base              = 1
          capacity_provider = "FARGATE"
          weight            = 1
        },
        {
          base              = 0
          capacity_provider = "FARGATE_SPOT"
          weight            = 5
        },
      ]
    }
  }
}
