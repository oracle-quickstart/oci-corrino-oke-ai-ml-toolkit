# Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

module "cluster-dynamic-group" {
  source = "./modules/oci-policies"

  providers = {
    oci             = oci
    oci.home_region = oci.home_region
  }

  # Oracle Cloud Infrastructure Tenancy
  tenancy_ocid = var.tenancy_ocid

  # Deployment Tags + Freeform Tags + Defined Tags
  oci_tag_values = local.oci_tag_values

  create_dynamic_group = true
  dynamic_group_name   = "OKE Cluster Nodes"
  dynamic_group_matching_rules = [
    "ALL {instance.compartment.id = '${local.oke_compartment_ocid}'}",
    "ALL {resource.type = 'cluster', resource.compartment.id = '${local.oke_compartment_ocid}'}"
  ]

  count = var.create_dynamic_group_for_nodes_in_compartment ? 1 : 0
}

module "cluster-compartment-policies" {
  source = "./modules/oci-policies"

  providers = {
    oci             = oci
    oci.home_region = oci.home_region
  }

  # Oracle Cloud Infrastructure Tenancy and Compartment OCID
  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = local.oke_compartment_ocid

  oci_tag_values = local.oci_tag_values

  create_policy = true
  policy_name   = "OKE Cluster Compartment Policies"
  policy_statements = [
    "Allow dynamic-group ${local.dynamic_group_name} to manage cluster-node-pools in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${local.dynamic_group_name} to manage instance-family in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${local.dynamic_group_name} to use subnets in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${local.dynamic_group_name} to read virtual-network-family in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${local.dynamic_group_name} to use vnics in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${local.dynamic_group_name} to inspect compartments in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${local.dynamic_group_name} to use network-security-groups in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${local.dynamic_group_name} to use private-ips in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${local.dynamic_group_name} to manage public-ips in compartment id ${local.oke_compartment_ocid}"
  ]

  count = var.create_compartment_policies ? 1 : 0
}

locals {
  dynamic_group_name = var.create_dynamic_group_for_nodes_in_compartment ? module.cluster-dynamic-group.0.dynamic_group_name : var.existent_dynamic_group_for_nodes_in_compartment
}