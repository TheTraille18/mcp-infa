variable "aws_region" {
  description = "AWS region for the MCP platform"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project tag / name prefix for shared MCP platform resources"
  type        = string
  default     = "mcp"
}

variable "environment" {
  description = "Deployment environment (prod only for now)"
  type        = string
  default     = "prod"
}

variable "aws_account_id" {
  description = "AWS account ID (for ECR image URIs)"
  type        = string
}

variable "kroger_client_id" {
  description = "Kroger OAuth client id (not secret; plain task env)"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for the ALB HTTPS listener. Leave empty to skip HTTPS for now."
  type        = string
  default     = ""
}

variable "grocery_mcp_image_tag" {
  description = "ECR image tag for grocery-mcp"
  type        = string
  default     = "latest"
}
