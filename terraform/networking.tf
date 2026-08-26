# Personal / first-pass: use the account default VPC (2+ public subnets for ALB).
# Replace with an explicit VPC later if you want private tasks + NAT.

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
