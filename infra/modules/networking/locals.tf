data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "current" {}

locals {
  az_count = {
    single   = 2
    failover = 2
    robust   = 3
  }

  subnet_size = {
    single   = 22
    failover = 21
    robust   = 20
  }

  selected_azs = slice(
    data.aws_availability_zones.available.names,
    0,
    local.az_count[var.redundancy]
  )

  vpc_prefix         = split("/", var.vpc_cidr_block)[1]
  subnet_newbits     = local.subnet_size[var.redundancy] - tonumber(local.vpc_prefix)
  total_subnet_pairs = local.az_count[var.redundancy]

  private_subnets = [
    for idx in range(local.total_subnet_pairs) :
    cidrsubnet(var.vpc_cidr_block, local.subnet_newbits, idx * 4)
  ]

  public_subnets = [
    for idx in range(local.total_subnet_pairs) :
    cidrsubnet(var.vpc_cidr_block, local.subnet_newbits, (idx * 4) + 2)
  ]

  azs = local.selected_azs
}