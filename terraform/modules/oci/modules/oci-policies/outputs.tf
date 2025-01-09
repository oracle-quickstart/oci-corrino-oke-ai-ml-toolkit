# Copyright (c) 2023 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

output "dynamic_group_id" {
  value = try(oci_identity_dynamic_group.for_policies.0.id, null)
}
output "dynamic_group_name" {
  value = try(oci_identity_dynamic_group.for_policies.0.name, null)
}
output "compartment_policy_id" {
  value = try(oci_identity_policy.policies.0.id, null)
}