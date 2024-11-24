# Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

resource "oci_identity_dynamic_group" "for_policies" {
  name           = "${local.app_name_normalized}-${local.dynamic_group_name_normalized}-${local.deploy_id}"
  description    = "${local.app_name} ${var.dynamic_group_name} (${local.deploy_id})"
  compartment_id = var.tenancy_ocid
  matching_rule  = "${var.dynamic_group_main_condition} {${join(",", var.dynamic_group_matching_rules)}}"
  freeform_tags  = var.oci_tag_values.freeformTags
  defined_tags   = var.oci_tag_values.definedTags

  provider = oci.home_region

  count = var.create_dynamic_group ? 1 : 0
}

resource "oci_identity_policy" "policies" {
  name           = "${local.app_name_normalized}-${local.policy_name_normalized}-${local.deploy_id}"
  description    = "${local.app_name} ${var.policy_name} (${local.deploy_id})"
  compartment_id = local.policy_compartment_ocid
  statements     = var.policy_statements
  freeform_tags  = var.oci_tag_values.freeformTags
  defined_tags   = var.oci_tag_values.definedTags

  depends_on = [oci_identity_dynamic_group.for_policies]

  provider = oci.home_region

  count = var.create_policy ? 1 : 0
}

locals {
  policy_compartment_ocid = var.compartment_ocid != "" ? var.compartment_ocid : var.tenancy_ocid
}