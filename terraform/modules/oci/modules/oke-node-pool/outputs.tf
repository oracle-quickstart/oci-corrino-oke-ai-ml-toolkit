# Copyright (c) 2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

output "node_pool_name" {
  value = var.create_new_node_pool ? oci_containerengine_node_pool.oke_node_pool.0.name : var.existent_oke_nodepool_id_for_autoscaler
}
output "node_pool_min_nodes" {
  value = var.node_pool_min_nodes
}
output "node_pool_max_nodes" {
  value = var.node_pool_max_nodes
}
output "node_pool_id" {
  value = var.create_new_node_pool ? oci_containerengine_node_pool.oke_node_pool.0.id : var.existent_oke_nodepool_id_for_autoscaler
}
output "node_k8s_version" {
  value = local.node_k8s_version
}
output "node_pool_autoscaler_enabled" {
  value = var.node_pool_autoscaler_enabled
}