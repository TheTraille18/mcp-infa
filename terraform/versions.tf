terraform {
  required_version = ">= 1.5.0"

  cloud {
    organization = "ablackcloudapp_test"

    workspaces {
      name = "mcp-prod"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
