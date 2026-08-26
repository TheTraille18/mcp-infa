locals {
  name_prefix = "${var.project_name}-${var.environment}"

  # Shared cluster for all MCP HTTP services
  cluster_name = var.project_name

  grocery_mcp_port = 3000
  grocery_mcp_image = format(
    "%s.dkr.ecr.%s.amazonaws.com/grocery-mcp:%s",
    var.aws_account_id,
    var.aws_region,
    var.grocery_mcp_image_tag,
  )
}
