# Copyright (c) 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# OKE Variables
## OKE Cluster Details
variable "create_new_compartment_for_oke" {
  default     = false
  description = "Creates new compartment for OKE Nodes and OCI Services deployed.  NOTE: The creation of the compartment increases the deployment time by at least 3 minutes, and can increase by 15 minutes when destroying"
}
variable "oke_compartment_description" {
  default = "Compartment for OKE, Nodes and Services"
}
variable "cluster_options_add_ons_is_kubernetes_dashboard_enabled" {
  default = false
}
variable "cluster_options_admission_controller_options_is_pod_security_policy_enabled" {
  description = "If true: The pod security policy admission controller will use pod security policies to restrict the pods accepted into the cluster."
  default     = false
}

## OKE Visibility (Workers and Endpoint)

variable "cluster_workers_visibility" {
  default     = "Private"
  description = "The Kubernetes worker nodes that are created will be hosted in public or private subnet(s)"

  validation {
    condition     = var.cluster_workers_visibility == "Private" || var.cluster_workers_visibility == "Public"
    error_message = "Sorry, but cluster visibility can only be Private or Public."
  }
}

variable "cluster_endpoint_visibility" {
  default     = "Public"
  description = "The Kubernetes cluster that is created will be hosted on a public subnet with a public IP address auto-assigned or on a private subnet. If Private, additional configuration will be necessary to run kubectl commands"

  validation {
    condition     = var.cluster_endpoint_visibility == "Private" || var.cluster_endpoint_visibility == "Public"
    error_message = "Sorry, but cluster endpoint visibility can only be Private or Public."
  }
}


## OKE Node Pool Details
variable "node_pool_name" {
  default     = "pool1"
  description = "Name of the node pool"
}
variable "k8s_version" {
  default     = "Latest"
  description = "Kubernetes version installed on your master and worker nodes"
}
variable "num_pool_workers" {
  default     = 3
  description = "The number of worker nodes in the node pool. If select Cluster Autoscaler, will assume the minimum number of nodes configured"
}

variable "node_pool_instance_shape" {
  type = map(any)
  default = {
    "instanceShape" = "VM.Standard.E3.Flex"
    "ocpus"         = 3
    "memory"        = 36
  }
  description = "A shape is a template that determines the number of OCPUs, amount of memory, and other resources allocated to a newly created instance for the Worker Node. Select at least 2 OCPUs and 16GB of memory if using Flex shapes"
}
variable "node_pool_boot_volume_size_in_gbs" {
  default     = "60"
  description = "Specify a custom boot volume size (in GB)"
}
variable "image_operating_system" {
  default     = "Oracle Linux"
  description = "The OS/image installed on all nodes in the node pool."
}
# variable "image_operating_system_version" {
#   default     = "8.10"
#   description = "The OS/image version installed on all nodes in the node pool."
# }
variable "generate_public_ssh_key" {
  default = true
}
variable "public_ssh_key" {
  default     = ""
  description = "In order to access your private nodes with a public SSH key you will need to set up a bastion host (a.k.a. jump box). If using public nodes, bastion is not needed. Left blank to not import keys."
}

# Network Details
## CIDRs
variable "network_cidrs" {
  type = map(string)

  default = {
    VCN-CIDR                      = "10.0.0.0/16"
    SUBNET-REGIONAL-CIDR          = "10.0.64.0/20"
    LB-SUBNET-REGIONAL-CIDR       = "10.0.96.0/20"
    ENDPOINT-SUBNET-REGIONAL-CIDR = "10.0.128.0/20"
    ALL-CIDR                      = "0.0.0.0/0"
    PODS-CIDR                     = "10.244.0.0/16"
    KUBERNETES-SERVICE-CIDR       = "10.96.0.0/16"
  }
}

# OCI Provider
variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}
variable "user_ocid" {
  default = ""
}
variable "fingerprint" {
  default = ""
}
variable "private_key_path" {
  default = ""
}

# ORM Schema visual control variables
variable "show_advanced" {
  default = false
}

# App Name Locals
locals {
  app_name            = random_string.app_name_autogen.result
  app_name_normalized = random_string.app_name_autogen.result
}

# Dictionary Locals
locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex",
    "VM.Standard.A1.Flex"
  ]
}