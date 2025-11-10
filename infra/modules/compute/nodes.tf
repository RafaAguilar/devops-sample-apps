resource "aws_eks_node_group" "this" {
  for_each = local.node_group_az_combinations

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = [each.value.subnet_id]

  capacity_type  = each.value.config.capacity_type
  instance_types = each.value.config.instance_types

  scaling_config {
    desired_size = each.value.config.scaling_config.desired_size
    max_size     = each.value.config.scaling_config.max_size
    min_size     = each.value.config.scaling_config.min_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role                          = each.value.node_group_key
    az                            = each.value.az_name
    "topology.kubernetes.io/zone" = each.value.az_name
    Name                          = each.key
  }

  tags = {
    AZ   = each.value.az_name
    Name = each.key
  }

  depends_on = [aws_iam_role_policy_attachment.nodes]

  lifecycle {
    ignore_changes = [
      scaling_config[0].desired_size,
    ]
  }
}
