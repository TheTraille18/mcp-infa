# mcp-infra

Terraform for the shared **MCP platform** on ECS Fargate: one cluster + ALB for all MCP HTTP servers (grocery first).

## Layout

```text
terraform/
  ecs.tf               # cluster, grocery task definition + service
  alb.tf               # shared ALB, grocery target group, listeners
  iam.tf               # ECS execution role + Secrets Manager access
  networking.tf        # default VPC / subnets (data sources)
  security_groups.tf
  secrets.tf           # looks up mcp/grocery-mcp/<env>/runtime
  ...
```

## Naming

| Resource     | Example                        |
|--------------|--------------------------------|
| ECS cluster  | `mcp`                          |
| ECS service  | `grocery-mcp`                  |
| Secret       | `mcp/grocery-mcp/prod/runtime` |
| ALB          | `mcp-prod-alb`                 |

## HCP Terraform

State and runs go to **HCP Terraform** (see `cloud` block in `versions.tf`).

1. Organization is **`ablackcloudapp_test`** in `versions.tf` (rename to `ablackcloudapp` in HCP when ready).
2. Create workspace **`mcp-prod`** (or let `terraform init` create it).
3. Authenticate: `terraform login`
4. In the workspace, set:
   - **Env vars:** `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` (and `AWS_SESSION_TOKEN` if needed), `AWS_DEFAULT_REGION=us-east-1`
   - **Terraform vars:** `aws_account_id`, `kroger_client_id`, optional `acm_certificate_arn`  
     (prefer HCP variables over committing `terraform.tfvars`)
5. If the workspace is VCS-driven, set **Working Directory** to `terraform`.

```bash
cd terraform
terraform init
terraform plan
```

Secret **values** stay outside Terraform (already created in Secrets Manager).
HTTPS listener is created only when `acm_certificate_arn` is set.
