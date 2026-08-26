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
| HCP org      | `ablackcloudapp_test`          |
| HCP project  | `mcp`                          |
| HCP workspace| `mcp-prod`                     |

## Workflow

- **Local:** `terraform plan` only (speculative run in HCP)
- **Apply:** via **VCS** (push/merge to the connected branch) — do not `terraform apply` locally

## HCP Terraform

State and remote runs use the `cloud` block in `versions.tf` (`ablackcloudapp_test` / `mcp-prod`).

### Auth (dynamic credentials)

Workspace **environment** variables:

| Key | Value |
|-----|--------|
| `TFC_AWS_PROVIDER_AUTH` | `true` |
| `TFC_AWS_RUN_ROLE_ARN` | `arn:aws:iam::398080922284:role/terraform-ablackcloudapp-role` |
| `AWS_DEFAULT_REGION` | `us-east-1` |

IAM role trust must allow:

`organization:ablackcloudapp_test:project:mcp:workspace:mcp-prod:run_phase:*`

Permissions: site policy + `terraform-mcp-policy` (ECS/ALB/EC2/Secrets/etc.).

### Terraform variables (workspace)

| Key | Notes |
|-----|--------|
| `aws_account_id` | e.g. `398080922284` |
| `kroger_client_id` | from grocery-mcp `.env` (not secret) |
| `acm_certificate_arn` | optional; omit until HTTPS cert exists |

### VCS

1. Push this repo to GitHub
2. Connect workspace `mcp-prod` to the repo
3. Working directory: `terraform`
4. Apply from merges to the tracked branch

### Local plan

```bash
cd terraform
terraform login   # once
terraform init
terraform plan    # speculative only
```

Secret **values** stay outside Terraform (Secrets Manager).  
HTTPS listener is created only when `acm_certificate_arn` is set.
