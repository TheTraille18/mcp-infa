resource "aws_ecs_cluster" "mcp" {
  name = local.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = local.cluster_name
  }
}

resource "aws_ecs_cluster_capacity_providers" "mcp" {
  cluster_name = aws_ecs_cluster.mcp.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
}

resource "aws_cloudwatch_log_group" "grocery_mcp" {
  name              = "/ecs/grocery-mcp"
  retention_in_days = 14
}

resource "aws_ecs_task_definition" "grocery_mcp" {
  family                   = "grocery-mcp"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([
    {
      name      = "grocery-mcp"
      image     = local.grocery_mcp_image
      essential = true

      portMappings = [
        {
          containerPort = local.grocery_mcp_port
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "PORT", value = tostring(local.grocery_mcp_port) },
        { name = "KROGER_CLIENT_ID", value = var.kroger_client_id }
      ]

      secrets = [
        {
          name      = "MCP_API_TOKEN"
          valueFrom = "${data.aws_secretsmanager_secret.grocery_mcp_runtime.arn}:MCP_API_TOKEN::"
        },
        {
          name      = "KROGER_CLIENT_SECRET"
          valueFrom = "${data.aws_secretsmanager_secret.grocery_mcp_runtime.arn}:KROGER_CLIENT_SECRET::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.grocery_mcp.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "grocery_mcp" {
  name            = "grocery-mcp"
  cluster         = aws_ecs_cluster.mcp.id
  task_definition = aws_ecs_task_definition.grocery_mcp.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.grocery_mcp.id]
    assign_public_ip = true # default VPC / no NAT; switch to private + NAT later if you want
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.grocery_mcp.arn
    container_name   = "grocery-mcp"
    container_port   = local.grocery_mcp_port
  }

  depends_on = [
    aws_lb_listener.http,
    aws_iam_role_policy.ecs_execution_secrets,
  ]
}
