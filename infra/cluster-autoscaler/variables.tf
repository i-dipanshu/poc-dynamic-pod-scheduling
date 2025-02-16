variable "aws_region" {
  description = "Region in which cluster is present"
  type        = string
  default     = "eu-west-1"
}

variable "eks_name" {
  description = "Name of the cluster."
  type        = string
}

variable "enable_cluster_autoscaler" {
  description = "Determines whether to deploy cluster autoscaler"
  type        = bool
  default     = false
}

variable "cluster_autoscaler_helm_version" {
  description = "Cluster Autoscaler Helm version"
  type        = string
}

variable "openid_provider_arn" {
  description = "IAM Openid Connect Provider ARN"
  type        = string
}