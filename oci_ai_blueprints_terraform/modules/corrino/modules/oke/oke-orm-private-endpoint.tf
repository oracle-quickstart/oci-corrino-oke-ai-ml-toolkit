# Copyright (c) 2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

### Important Notice ###
# OCI Resource Manager Private Endpoint is only available when using Resource Manager.
# If you use local Terraform, you will need to setup an OCI Bastion for connectivity to the Private OKE.
# If using OCI CloudShell, you need to activate the OCI Private Endpoint for OCI CLoud Shell.

resource "oci_resourcemanager_private_endpoint" "private_kubernetes_endpoint" {
  compartment_id = local.oke_compartment_ocid
  display_name   = "Private Endpoint for OKE ${local.app_name} - ${local.deploy_id}"
  description    = "Resource Manager Private Endpoint for OKE for the ${local.app_name} - ${local.deploy_id}"
  vcn_id         = var.vcn_id
  subnet_id      = var.k8s_endpoint_subnet_id
  freeform_tags  = var.cluster_tags.freeformTags
  defined_tags   = var.cluster_tags.definedTags

  count = var.create_new_oke_cluster ? ((var.cluster_endpoint_visibility == "Private") ? 1 : 0) : 0
}

# Resolves the private IP of the customer's private endpoint to a NAT IP.
data "oci_resourcemanager_private_endpoint_reachable_ip" "private_kubernetes_endpoint" {
  private_endpoint_id = var.create_new_oke_cluster ? oci_resourcemanager_private_endpoint.private_kubernetes_endpoint[0].id : var.existent_oke_cluster_private_endpoint
  private_ip          = trimsuffix(oci_containerengine_cluster.oke_cluster[0].endpoints.0.private_endpoint, ":6443") # TODO: Pending rule when has existent cluster

  count = (var.cluster_endpoint_visibility == "Private") ? 1 : 0
}