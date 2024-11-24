# Copyright (c) 2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

output "oci_vault_key_id" {
  value = var.use_encryption_from_oci_vault ? (var.create_new_encryption_key ? oci_kms_key.oke_key[0].id : var.existent_encryption_key_id) : null
}