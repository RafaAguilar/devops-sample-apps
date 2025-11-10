data "aws_region" "current" {}

locals {
  node_group_az_combinations = merge([
    for ng_key, ng_config in var.node_groups : {
      for idx, subnet_id in var.subnet_ids :
      "${var.env}-${var.availability_zones[idx]}-${ng_key}-nodegroup" => {
        node_group_key = ng_key
        config         = ng_config
        az_index       = idx
        subnet_id      = subnet_id
        az_name        = var.availability_zones[idx]
      }
    }
  ]...)
}