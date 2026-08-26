output "ecs_cluster_name" {
  description = "Shared ECS cluster for all MCP services"
  value       = aws_ecs_cluster.mcp.name
}

output "ecs_cluster_arn" {
  description = "ARN of the shared MCP ECS cluster"
  value       = aws_ecs_cluster.mcp.arn
}

output "alb_dns_name" {
  description = "DNS name of the shared MCP ALB"
  value       = aws_lb.mcp.dns_name
}

output "alb_arn" {
  description = "ARN of the shared MCP ALB"
  value       = aws_lb.mcp.arn
}

output "grocery_mcp_secret_arn" {
  description = "ARN of grocery-mcp runtime secret (values managed outside Terraform)"
  value       = data.aws_secretsmanager_secret.grocery_mcp_runtime.arn
}

output "grocery_mcp_service_name" {
  description = "ECS service name for grocery-mcp"
  value       = aws_ecs_service.grocery_mcp.name
}
