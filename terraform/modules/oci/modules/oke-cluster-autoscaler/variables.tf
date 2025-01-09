# Copyright (c) 2022, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# OKE Variables
## OKE Autoscaler
# variable "cluster_autoscaler_enabled" {
#   default     = true
#   description = "Enables OKE cluster autoscaler. Node pools will auto scale based on the resources usage"
# }
variable "cluster_autoscaler_supported_k8s_versions" {
  type = map(string)

  default     = { "1.22" = "1.22.2-4", "1.23" = "1.23.0-4", "1.24" = "1.24.0-5", "1.25" = "1.25.0-6" } # There's no API to get that list. Need to be updated manually
  description = "Supported Kubernetes versions for OKE cluster autoscaler"
}
variable "custom_cluster_autoscaler_image" {
  default     = ""
  description = "Custom Image for OKE cluster autoscaler"
}
variable "cluster_autoscaler_log_level_verbosity" {
  default     = 4
  description = "Log level verbosity for OKE cluster autoscaler"
}
variable "cluster_autoscaler_max_node_provision_time" {
  default     = "25m"
  description = "Maximum time in minutes for a node to be provisioned. If the node is not ready after this time, it will be deleted and recreated"
}
variable "cluster_autoscaler_scale_down_delay_after_add" {
  default     = "10m"
  description = "Time to wait after scale up before attempting to scale down"
}
variable "cluster_autoscaler_scale_down_unneeded_time" {
  default     = "10m"
  description = "Time after which a node should be deleted after it has been unneeded for this long"
}
variable "cluster_autoscaler_unremovable_node_recheck_timeout" {
  default     = "5m"
  description = "Time after which a node which failed to be removed is retried"
}
variable "cluster_autoscaler_num_of_replicas" {
  default     = 3
  description = "Number of replicas for OKE cluster autoscaler"
}
variable "cluster_autoscaler_extra_args" {
  default     = []
  description = "Extra arguments to pass to OKE cluster autoscaler"
}

## OKE Node Pool Details
variable "oke_node_pools" {
  type = list(any)

  default     = []
  description = "Node pools (id, min_nodes, max_nodes, k8s_version) to use with Cluster Autoscaler"
}

# OCI Provider
variable "region" {}

# Get OKE options
locals {
  node_pool_k8s_latest_version = reverse(sort(data.oci_containerengine_node_pool_option.node_pool.kubernetes_versions))[0]
}