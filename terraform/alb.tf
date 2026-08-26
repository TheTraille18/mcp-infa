resource "aws_lb" "mcp" {
  name               = "${local.name_prefix}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.default.ids

  tags = {
    Name = "${local.name_prefix}-alb"
  }
}

resource "aws_lb_target_group" "grocery_mcp" {
  name        = "${local.name_prefix}-grocery-mcp"
  port        = local.grocery_mcp_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.default.id

  health_check {
    enabled             = true
    path                = "/mcp"
    matcher             = "200-499" # MCP may reject unauthenticated probes; keep tasks healthy
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${local.name_prefix}-grocery-mcp"
  }
}

# Default forward to grocery-mcp until more services need host/path rules.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.mcp.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grocery_mcp.arn
  }
}

# Set acm_certificate_arn in tfvars when the cert is ready.
resource "aws_lb_listener" "https" {
  count = var.acm_certificate_arn != "" ? 1 : 0

  load_balancer_arn = aws_lb.mcp.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grocery_mcp.arn
  }
}
