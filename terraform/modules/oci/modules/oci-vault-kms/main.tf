# Copyright (c) 2021, 2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

##**************************************************************************
##                            OCI KMS Vault
##**************************************************************************

### OCI Vault vault
resource "oci_kms_vault" "oke_vault" {
  compartment_id = var.oke_cluster_compartment_ocid
  display_name   = "${local.vault_display_name} - ${local.deploy_id}"
  vault_type     = local.vault_type[0]
  freeform_tags  = var.oci_tag_values.freeformTags
  defined_tags   = var.oci_tag_values.definedTags

  # depends_on = [oci_identity_policy.kms_user_group_compartment_policies]

  count = var.use_encryption_from_oci_vault ? (var.create_new_encryption_key ? 1 : 0) : 0
}
### OCI Vault key
resource "oci_kms_key" "oke_key" {
  compartment_id      = var.oke_cluster_compartment_ocid
  display_name        = "${local.vault_key_display_name} - ${local.deploy_id}"
  management_endpoint = oci_kms_vault.oke_vault[0].management_endpoint
  protection_mode     = local.vault_key_protection_mode
  freeform_tags       = var.oci_tag_values.freeformTags
  defined_tags        = var.oci_tag_values.definedTags

  key_shape {
    algorithm = local.vault_key_key_shape_algorithm
    length    = local.vault_key_key_shape_length
  }

  count = var.use_encryption_from_oci_vault ? (var.create_new_encryption_key ? 1 : 0) : 0
}

### Vault and Key definitions
locals {
  vault_display_name            = "OKE Vault"
  vault_key_display_name        = "OKE Key"
  vault_key_key_shape_algorithm = "AES"
  vault_key_key_shape_length    = 32
  vault_type                    = ["DEFAULT", "VIRTUAL_PRIVATE"]
  vault_key_protection_mode     = "SOFTWARE" # HSM or SOFTWARE
  oci_vault_key_id              = var.use_encryption_from_oci_vault ? (var.create_new_encryption_key ? oci_kms_key.oke_key[0].id : var.existent_encryption_key_id) : "void"
}