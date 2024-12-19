resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = var.subnet_ids

  capacity_type  = each.value.capacity_type
  instance_types = each.value.instance_types
  disk_size      = each.value.disk_size

  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    max_size     = each.value.scaling_config.max_size
    min_size     = each.value.scaling_config.min_size
  }

  dynamic "taint" {
    for_each = each.value.taint_enabled ? [each.value.taints] : []
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    size = each.key
  }

  tags = merge(
    each.value.taint_enabled ? {
      "k8s.io/cluster-autoscaler/node-template/label/size" = each.key
    } : {},
    each.value.taint_enabled ? {
      "k8s.io/cluster-autoscaler/node-template/taint/${each.value.taints.key}" = "${each.value.taints.value}:${each.value.taints.tag_effect}"
    } : {}
  )

  depends_on = [aws_iam_role_policy_attachment.nodes]
}