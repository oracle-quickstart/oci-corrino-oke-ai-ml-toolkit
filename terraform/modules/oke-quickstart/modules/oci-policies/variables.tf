# Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

# Create Dynamic Group and Policies
variable "create_dynamic_group" {
  default     = false
  description = "Creates dynamic group to use with policies. Note: You need to have proper rights on the Tenancy. If you only have rights in a compartment, uncheck and ask you administrator to create the Dynamic Group for you"
}
variable "dynamic_group_name" {
  default     = "Dynamic Group"
  description = "Name of the dynamic group. e.g.: OKE Cluster Dynamic Group => <app_name>-oke-cluster-dynamic-group-<deploy_id>"
}
## Dynamic Group Matching Rules
variable "dynamic_group_matching_rules" {
  type        = list(string)
  default     = []
  description = "List of matching rules for the dynamic group. e.g.: [\"ALL {instance.compartment.id = 'ocid1.compartment.oc1..aaaaaaaaxxxxxxxxxxxxxxxx'}\", \"ALL {instance.id = 'ocid1.instance.oc1.phx.xxxxxxxx'}\"]"
}
variable "dynamic_group_main_condition" {
  default     = "ANY"
  description = "Main condition for the dynamic group. e.g.: ALL, ANY"

  validation {
    condition     = var.dynamic_group_main_condition == "ALL" || var.dynamic_group_main_condition == "ANY"
    error_message = "Sorry, but cluster visibility can only be ALL or ANY."
  }
}
# Policy
variable "create_policy" {
  default     = false
  description = "Creates policy. e.g.: Compartment Policies to support Cluster Autoscaler, OCI Logging datasource on Grafana; Tenancy Policies to support OCI Metrics datasource on Grafana"
}
variable "policy_name" {
  default     = "Policies"
  description = "Name of the policy. e.g.: Compartment Policies => <app_name>-compartment-policies-<deploy_id>"
}
# variable "create_tenancy_policies" {
#   default     = false
#   description = "Creates policies that need to reside on the tenancy. e.g.: Policies to support OCI Metrics datasource on Grafana"
# }
variable "compartment_ocid" {
  default     = ""
  description = "Compartment OCID where the policies will be created. If not specified, the policies will be created on the Tenancy OCID"
}

# Compartment Policies Statements
variable "policy_statements" {
  type        = list(string)
  default     = []
  description = "List of statements for the compartment policy. e.g.: [\"Allow dynamic-group <DynamicGroupName> to manage instances in compartment <compartment>\", \"Allow dynamic-group <DynamicGroupName> to use instances in compartment <compartment> where ALL {instance.compartment.id = 'ocid1.compartment.oc1..aaaaaaaaxxxxxxxxxxxxxxxx', instance.id = 'ocid1.instance.oc1.phx.xxxxxxxx'}\"]"
}

# Deployment Details + Freeform Tags
variable "oci_tag_values" {
  description = "Tags to be added to the resources"
}

# OCI Provider
variable "tenancy_ocid" {}
# variable "region" {}
# variable "user_ocid" { default = "" }
# variable "fingerprint" { default = "" }
# variable "private_key_path" { default = "" }

locals {
  app_name_normalized           = substr(replace(lower(var.oci_tag_values.freeformTags.AppName), " ", "-"), 0, 6)
  app_name                      = var.oci_tag_values.freeformTags.AppName
  deploy_id                     = var.oci_tag_values.freeformTags.DeploymentID
  policy_compartment_OCID       = var.compartment_ocid == "" ? var.tenancy_ocid : var.compartment_ocid
  dynamic_group_name_normalized = substr(replace(lower(var.dynamic_group_name), " ", "-"), 0, 80)
  policy_name_normalized        = substr(replace(lower(var.policy_name), " ", "-"), 0, 80)
}