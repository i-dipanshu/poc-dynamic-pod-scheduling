variable "tags" {
  default     = {}
  type        = map(string)
  description = "Extra tags to attach to the EKS resources"
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs"
}

variable "application" {
  type        = string
  description = "The name of the application this cluster belongs to"
  default     = "poc"
}

variable "environment" {
  type        = string
  description = "The environment where this cluster lives"
}

variable "eks_version" {
  description = "Desired Kubernetes control plain version"
  type        = string
}

variable "taint_enabled" {
  description = "Flag to enable or disable taints"
  type        = bool
  default     = true
}

variable "node_iam_policies" {
  description = "List of IAM Policies to attach to EKS-managed nodes"
  type        = map(any)
  default = {
    1 = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    2 = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    3 = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    4 = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

variable "node_groups" {
  description = "Map of node group configurations"
  type = map(object({
    capacity_type  = string
    instance_types = list(string)
    disk_size      = string
    taint_enabled  = bool
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
    taints = optional(object({
      key    = string
      value  = string
      effect = string
      tag_effect = string
    }))
  }))
}

variable "enable_irsa" {
  description = "Determines whether to create an OpenID Connect Provider for EKS to enable IRSA"
  type        = bool
  default     = true
}