# Copyright (c) 2022, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# OKE Variables
variable "oke_cluster_ocid" {
  description = "OKE cluster OCID"
  type        = string
}
variable "oke_cluster_compartment_ocid" {
  description = "Compartment OCID used by the OKE Cluster"
  type        = string
}

## Node Pool Variables
variable "create_new_node_pool" {
  default     = true
  description = "Create a new node pool if true or use an existing one if false"
}
variable "node_k8s_version" {
  description = "Kubernetes version installed on your worker nodes"
  type        = string
  default     = "Latest"
}
variable "node_pool_name" {
  default     = "pool1"
  description = "Name of the node pool"
}
variable "extra_initial_node_labels" {
  default     = {}
  description = "Extra initial node labels to be added to the node pool"
}
variable "node_pool_min_nodes" {
  default     = 3
  description = "The number of worker nodes in the node pool. If select Cluster Autoscaler, will assume the minimum number of nodes configured"
}
variable "node_pool_max_nodes" {
  default     = 3
  description = "The max number of worker nodes in the node pool if using Cluster Autoscaler."
}
variable "node_pool_shape" {
  default     = "VM.Standard.E4.Flex"
  description = "A shape is a template that determines the number of OCPUs, amount of memory, and other resources allocated to a newly created instance for the Worker Node"
}
variable "node_pool_node_shape_config_ocpus" {
  default     = "2" # Only used if flex shape is selected
  description = "You can customize the number of OCPUs to a flexible shape"
}
variable "node_pool_node_shape_config_memory_in_gbs" {
  default     = "16" # Only used if flex shape is selected
  description = "You can customize the amount of memory allocated to a flexible shape"
}
variable "node_pool_shape_specific_ad" {
  description = "The number of the AD to get the shape for the node pool"
  type        = number
  default     = 0

  validation {
    condition     = var.node_pool_shape_specific_ad >= 0 && var.node_pool_shape_specific_ad <= 3
    error_message = "Invalid AD number, should be 0 to get all ADs or 1, 2 or 3 to be a specific AD."
  }
}
variable "cni_type" {
  default     = "FLANNEL_OVERLAY"
  description = "The CNI type to use for the cluster. Valid values are: FLANNEL_OVERLAY or OCI_VCN_IP_NATIVE"

  validation {
    condition     = var.cni_type == "FLANNEL_OVERLAY" || var.cni_type == "OCI_VCN_IP_NATIVE"
    error_message = "Sorry, but OKE currently only supports FLANNEL_OVERLAY or OCI_VCN_IP_NATIVE CNI types."
  }
}
variable "existent_oke_nodepool_id_for_autoscaler" {
  default     = ""
  description = "Nodepool Id of the existent OKE to use with Cluster Autoscaler"
}
variable "node_pool_autoscaler_enabled" {
  default     = true
  description = "Enable Cluster Autoscaler for the node pool"
}
variable "image_operating_system" {
  default     = "Oracle Linux"
  description = "The OS/image installed on all nodes in the node pool."
}
variable "image_operating_system_version" {
  default     = "8"
  description = "The OS/image version installed on all nodes in the node pool."
}
variable "node_pool_boot_volume_size_in_gbs" {
  default     = "50"
  description = "Specify a custom boot volume size (in GB)"
}
variable "node_pool_oke_init_params" {
  type        = string
  default     = ""
  description = "OKE Init params"
}
variable "node_pool_cloud_init_parts" {
  type = list(object({
    content_type = string
    content      = string
    filename     = string
  }))
  default     = []
  description = "Node Pool nodes Cloud init parts"
}
variable "public_ssh_key" {
  default     = ""
  description = "In order to access your private nodes with a public SSH key you will need to set up a bastion host (a.k.a. jump box). If using public nodes, bastion is not needed. Left blank to not import keys."
}

# OKE Network Variables
variable "nodes_subnet_id" { description = "Nodes Subnet OCID to deploy OKE Cluster" }
variable "vcn_native_pod_networking_subnet_ocid" {
  default     = ""
  description = "VCN Native Pod Networking Subnet OCID used by the OKE Cluster"
}

# Customer Manager Encryption Keys
variable "oci_vault_key_id_oke_node_boot_volume" {
  description = "OCI Vault Key OCID used to encrypt the OKE node boot volume"
  type        = string
  default     = null
}

# OCI Provider
variable "tenancy_ocid" {}

# App Name Locals
locals {
  app_name_normalized = substr(replace(lower(var.node_pools_tags.freeformTags.AppName), " ", "-"), 0, 6)
}

# Deployment Details + Freeform Tags
variable "node_pools_tags" {
  description = "Tags to be added to the node pools resources"
}
variable "worker_nodes_tags" {
  description = "Tags to be added to the worker nodes resources"
}