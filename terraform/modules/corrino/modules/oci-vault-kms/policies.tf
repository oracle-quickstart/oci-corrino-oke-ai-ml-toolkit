# Copyright (c) 2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

resource "oci_identity_dynamic_group" "app_dynamic_group" {
  name           = "${local.app_name_normalized}-kms-dg-${local.deploy_id}"
  description    = "${local.app_name} KMS for OKE Dynamic Group (${local.deploy_id})"
  compartment_id = var.tenancy_ocid
  matching_rule  = "ANY {${join(",", local.dynamic_group_matching_rules)}}"

  provider = oci.home_region

  count = (var.use_encryption_from_oci_vault && var.create_dynamic_group_for_nodes_in_compartment) ? 1 : 0
}
resource "oci_identity_policy" "app_compartment_policies" {
  name           = "${local.app_name_normalized}-kms-compartment-policies-${local.deploy_id}"
  description    = "${local.app_name} KMS for OKE Compartment Policies (${local.deploy_id})"
  compartment_id = var.oke_cluster_compartment_ocid
  statements     = local.app_compartment_statements

  depends_on = [oci_identity_dynamic_group.app_dynamic_group]

  provider = oci.home_region

  count = (var.use_encryption_from_oci_vault && var.create_compartment_policies) ? 1 : 0
}
resource "oci_identity_policy" "kms_user_group_compartment_policies" {
  name           = "${local.app_name_normalized}-kms-compartment-policies-${local.deploy_id}"
  description    = "${local.app_name} KMS User Group Compartment Policies (${local.deploy_id})"
  compartment_id = var.oke_cluster_compartment_ocid
  statements     = local.kms_user_group_compartment_statements

  depends_on = [oci_identity_dynamic_group.app_dynamic_group]

  provider = oci.home_region

  count = (var.use_encryption_from_oci_vault && var.create_compartment_policies && var.create_vault_policies_for_group) ? 1 : 0
}

# Concat Matching Rules and Policy Statements
locals {
  dynamic_group_matching_rules = concat(
    local.instances_in_compartment_rule,
    local.clusters_in_compartment_rule
  )
  app_compartment_statements = concat(
    local.allow_oke_use_oci_vault_keys_statements
  )
  kms_user_group_compartment_statements = concat(
    local.allow_group_manage_vault_keys_statements
  )
}

# Individual Rules
locals {
  instances_in_compartment_rule = ["ALL {instance.compartment.id = '${var.oke_cluster_compartment_ocid}'}"]
  clusters_in_compartment_rule  = ["ALL {resource.type = 'cluster', resource.compartment.id = '${var.oke_cluster_compartment_ocid}'}"]
}

# Individual Policy Statements
locals {
  allow_oke_use_oci_vault_keys_statements = [
    "Allow service oke to use vaults in compartment id ${var.oke_cluster_compartment_ocid}",
    "Allow service oke to use keys in compartment id ${var.oke_cluster_compartment_ocid} where target.key.id = '${local.oci_vault_key_id}'",
    "Allow service oke to use key-delegates in compartment id ${var.oke_cluster_compartment_ocid} where target.key.id = '${local.oci_vault_key_id}'",
    "Allow service blockstorage to use keys in compartment id ${var.oke_cluster_compartment_ocid} where target.key.id = '${local.oci_vault_key_id}'",
    "Allow dynamic-group ${local.app_dynamic_group} to use keys in compartment id ${var.oke_cluster_compartment_ocid} where target.key.id = '${local.oci_vault_key_id}'",
    "Allow dynamic-group ${local.app_dynamic_group} to use key-delegates in compartment id ${var.oke_cluster_compartment_ocid} where target.key.id = '${local.oci_vault_key_id}'"
  ]
  allow_group_manage_vault_keys_statements = [
    "Allow group ${var.user_admin_group_for_vault_policy} to manage vaults in compartment id ${var.oke_cluster_compartment_ocid}",
    "Allow group ${var.user_admin_group_for_vault_policy} to manage keys in compartment id ${var.oke_cluster_compartment_ocid}",
    "Allow group ${var.user_admin_group_for_vault_policy} to use key-delegate in compartment id ${var.oke_cluster_compartment_ocid}"
  ]
}
