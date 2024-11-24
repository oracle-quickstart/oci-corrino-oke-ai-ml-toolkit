# Copyright (c) 2021-2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

data "oci_containerengine_cluster_option" "oke" {
  cluster_option_id = "all"
}
data "oci_containerengine_clusters" "oke" {
  compartment_id = local.oke_compartment_ocid
}

# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

# Gets kubeconfig
data "oci_containerengine_cluster_kube_config" "oke" {
  cluster_id = var.create_new_oke_cluster ? oci_containerengine_cluster.oke_cluster[0].id : var.existent_oke_cluster_id
}
