# Secret values are created outside Terraform (console/CLI).
# Terraform only looks them up for ECS task wiring.

data "aws_secretsmanager_secret" "grocery_mcp_runtime" {
  name = "mcp/grocery-mcp/${var.environment}/runtime"
}
