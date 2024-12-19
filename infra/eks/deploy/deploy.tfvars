# Define Subnets, Application, and Environment
subnet_ids  = ["subnet-090b7547b19ef3d3f", "subnet-09c89c34269343c9c"]
application = "nginx"
environment = "test"
eks_version = "1.31"
tags = {
  "usage" = "poc"
}

node_groups = {
  general = {
    capacity_type  = "ON_DEMAND"  
    instance_types = ["t3a.medium"]
    disk_size      = "20"
    taint_enabled  = false
    scaling_config = {
      desired_size = 1
      max_size     = 1
      min_size     = 1
    }
  }
  large = {
    capacity_type  = "ON_DEMAND"  # size=large:NoSchedule
    instance_types = ["t3a.xlarge"]  # 4000Mi 16Gi
    disk_size      = "20"
    taint_enabled  = true
    scaling_config = {
      desired_size = 1 # using 0 introduces a bug
      min_size     = 1
      max_size     = 2
    }
    taints = {
      key    = "size"
      value  = "large"
      effect = "NO_SCHEDULE"
      tag_effect     = "NoSchedule"
    }
  }
  medium = {
    capacity_type  = "ON_DEMAND"  # size=medium:NoSchedule
    instance_types = ["t3a.medium"]  # 2000Mi 4Gi
    disk_size      = "100"
    taint_enabled  = true
    scaling_config = {
      desired_size = 1 # using 0 introduces a bug
      min_size     = 1
      max_size     = 2
    }
    taints = {
      key    = "size"
      value  = "medium"
      effect = "NO_SCHEDULE"
      tag_effect    = "NoSchedule" 
    }
  }
}

enable_irsa = true