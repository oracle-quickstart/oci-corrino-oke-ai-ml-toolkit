# Copyright (c) 2021, 2022, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# OKE Encryption details
variable "use_encryption_from_oci_vault" {
  default     = false
  description = "By default, Oracle manages the keys that encrypts Kubernetes Secrets at Rest in Etcd, but you can choose a key from a vault that you have access to, if you want greater control over the key's lifecycle and how it's used"
}
variable "create_new_encryption_key" {
  default     = false
  description = "Creates new vault and key on OCI Vault/Key Management/KMS and assign to boot volume of the worker nodes"
}
variable "existent_encryption_key_id" {
  default     = ""
  description = "Use an existent master encryption key to encrypt boot volume and object storage bucket. NOTE: If the key resides in a different compartment or in a different tenancy, make sure you have the proper policies to access, or the provision of the worker nodes will fail"
}

# Deployment Details + Freeform Tags
variable "oci_tag_values" {
  description = "Tags to be added to the resources"
}

# OKE Variables
variable "oke_cluster_compartment_ocid" {
  description = "Compartment OCID used by the OKE Cluster"
  type        = string
}

# Policies variables
variable "create_vault_policies_for_group" {
  default     = false
  description = "Creates policies to allow the user applying the stack to manage vault and keys. If you are on the Administrators group or already have the policies for a compartment, this policy is not needed. If you do not have access to allow the policy, ask your administrator to include it for you"
}
variable "user_admin_group_for_vault_policy" {
  default     = "Administrators"
  description = "User Identity Group to allow manage vault and keys. The user running the Terraform scripts or Applying the ORM Stack need to be on this group"
}
## Create Dynamic Group and Policies
variable "create_dynamic_group_for_nodes_in_compartment" {
  default     = false
  description = "Creates dynamic group of Nodes in the compartment. Note: You need to have proper rights on the Tenancy. If you only have rights in a compartment, uncheck and ask you administrator to create the Dynamic Group for you"
}
variable "create_compartment_policies" {
  default     = false
  description = "Creates policies for KMS that will reside on the compartment."
}

# OCI Provider
variable "tenancy_ocid" {}

# Conditional locals
locals {
  app_dynamic_group   = (var.use_encryption_from_oci_vault && var.create_dynamic_group_for_nodes_in_compartment) ? oci_identity_dynamic_group.app_dynamic_group.0.name : "void"
  app_name_normalized = substr(replace(lower(var.oci_tag_values.freeformTags.AppName), " ", "-"), 0, 6)
  app_name            = var.oci_tag_values.freeformTags.AppName
  deploy_id           = var.oci_tag_values.freeformTags.DeploymentID
}