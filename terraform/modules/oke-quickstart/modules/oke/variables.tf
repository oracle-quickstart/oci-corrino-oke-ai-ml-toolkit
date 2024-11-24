# Copyright (c) 2021, 2022, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# OCI Provider
variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}

# Network Details
variable "vcn_id" { description = "VCN OCID to deploy OKE Cluster" }
variable "k8s_endpoint_subnet_id" { description = "Kubernetes Endpoint Subnet OCID to deploy OKE Cluster" }
variable "lb_subnet_id" { description = "Load Balancer Subnet OCID to deploy OKE Cluster" }
variable "cluster_workers_visibility" {
  default     = "Private"
  description = "The Kubernetes worker nodes that are created will be hosted in public or private subnet(s)"
}
variable "cluster_endpoint_visibility" {
  default     = "Public"
  description = "The Kubernetes cluster that is created will be hosted on a public subnet with a public IP address auto-assigned or on a private subnet. If Private, additional configuration will be necessary to run kubectl commands"
}
variable "network_cidrs" {}
variable "cni_type" {
  default     = "FLANNEL_OVERLAY"
  description = "The CNI type to use for the cluster. Valid values are: FLANNEL_OVERLAY or OCI_VCN_IP_NATIVE"

  validation {
    condition     = var.cni_type == "FLANNEL_OVERLAY" || var.cni_type == "OCI_VCN_IP_NATIVE"
    error_message = "Sorry, but OKE currently only supports FLANNEL_OVERLAY or OCI_VCN_IP_NATIVE CNI types."
  }
}

# OKE Variables
## OKE Cluster Details
variable "create_new_oke_cluster" {
  default     = false
  description = "Creates a new OKE cluster and node pool"
}
variable "existent_oke_cluster_id" {
  default     = ""
  description = "Using existent OKE Cluster. Only the application and services will be provisioned. If select cluster autoscaler feature, you need to get the node pool id and enter when required"
}
variable "cluster_type" {
  default     = "BASIC_CLUSTER"
  description = "The type of OKE cluster to create. Valid values are: BASIC_CLUSTER or ENHANCED_CLUSTER"
}
variable "create_orm_private_endpoint" {
  default     = false
  description = "Creates a new private endpoint for the OKE cluster"
}
variable "existent_oke_cluster_private_endpoint" {
  default     = ""
  description = "Resource Manager Private Endpoint to access the OKE Private Cluster"
}
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

## OKE Encryption details
variable "oci_vault_key_id_oke_secrets" {
  default     = null
  description = "OCI Vault OCID to encrypt OKE secrets. If not provided, the secrets will be encrypted with the default key"
}
variable "oci_vault_key_id_oke_image_policy" {
  default     = null
  description = "OCI Vault OCID for the Image Policy"
}

variable "create_vault_policies_for_group" {
  default     = false
  description = "Creates policies to allow the user applying the stack to manage vault and keys. If you are on the Administrators group or already have the policies for a compartment, this policy is not needed. If you do not have access to allow the policy, ask your administrator to include it for you"
}
variable "user_admin_group_for_vault_policy" {
  default     = "Administrators"
  description = "User Identity Group to allow manage vault and keys. The user running the Terraform scripts or Applying the ORM Stack need to be on this group"
}

variable "k8s_version" {
  default     = "Latest"
  description = "Kubernetes version installed on your Control Plane"
}

# Create Dynamic Group and Policies
# variable "create_dynamic_group_for_nodes_in_compartment" {
#   default     = false # TODO: true 
#   description = "Creates dynamic group of Nodes in the compartment. Note: You need to have proper rights on the Tenancy. If you only have rights in a compartment, uncheck and ask you administrator to create the Dynamic Group for you"
# }
# variable "existent_dynamic_group_for_nodes_in_compartment" {
#   default     = ""
#   description = "Enter previous created Dynamic Group for the policies"
# }
# variable "create_compartment_policies" {
#   default     = false # TODO: true 
#   description = "Creates policies that will reside on the compartment. e.g.: Policies to support Cluster Autoscaler, OCI Logging datasource on Grafana"
# }
# variable "create_tenancy_policies" {
#   default     = false # TODO: true 
#   description = "Creates policies that need to reside on the tenancy. e.g.: Policies to support OCI Metrics datasource on Grafana"
# }

# ORM Schema visual control variables
variable "show_advanced" {
  default = false
}

# App Name Locals
locals {
  app_name            = var.cluster_tags.freeformTags.AppName
  deploy_id           = var.cluster_tags.freeformTags.DeploymentID
  app_name_normalized = substr(replace(lower(var.cluster_tags.freeformTags.AppName), " ", "-"), 0, 6)
  app_name_for_dns    = substr(lower(replace(var.cluster_tags.freeformTags.AppName, "/\\W|_|\\s/", "")), 0, 6)
}

# OKE Compartment
locals {
  oke_compartment_ocid = var.compartment_ocid
}

# Deployment Details + Freeform Tags
variable "cluster_tags" {
  description = "Tags to be added to the cluster resources"
}
variable "load_balancers_tags" {
  description = "Tags to be added to the load balancers resources"
}
variable "block_volumes_tags" {
  description = "Tags to be added to the block volumes resources"
}