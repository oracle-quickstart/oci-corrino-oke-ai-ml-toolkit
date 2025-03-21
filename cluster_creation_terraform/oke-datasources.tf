# Copyright (c) 2020-2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# data "oci_core_image_shapes" "test_image_shapes" {
#     #Required
#     image_id = oci_core_image.test_image.id
# }

# Gets a list of supported images based on the shape, operating_system and operating_system_version provided
data "oci_core_images" "shape_specific_images" {
  compartment_id = local.oke_compartment_ocid
  #operating_system = var.image_operating_system
  shape = var.node_pool_instance_shape.instanceShape
  #sort_by          = "TIMECREATED"
  #sort_order       = "DESC"
}

data "oci_containerengine_node_pool_option" "cluster_node_pool_option" {
  #Required
  node_pool_option_id = oci_containerengine_cluster.oke_cluster[0].id

  depends_on = [oci_containerengine_cluster.oke_cluster]
}

data "oci_containerengine_cluster_option" "oke" {
  cluster_option_id = "all"
}
data "oci_containerengine_node_pool_option" "oke" {
  node_pool_option_id = "all"
}
data "oci_containerengine_clusters" "oke" {
  compartment_id = local.oke_compartment_ocid
}

# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

# Gets home and current regions
data "oci_identity_tenancy" "tenant_details" {
  tenancy_id = var.tenancy_ocid

  provider = oci.current_region
}

data "oci_identity_regions" "home_region" {
  filter {
    name   = "key"
    values = [data.oci_identity_tenancy.tenant_details.home_region_key]
  }

  provider = oci.current_region
}

# Gets kubeconfig
data "oci_containerengine_cluster_kube_config" "oke" {
  cluster_id = oci_containerengine_cluster.oke_cluster[0].id

  depends_on = [oci_containerengine_node_pool.oke_node_pool]
}

# OCI Services
## Available Services
data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

## Object Storage
data "oci_objectstorage_namespace" "ns" {
  compartment_id = local.oke_compartment_ocid
}

# Randoms
resource "random_string" "deploy_id" {
  length  = 4
  special = false
}

resource "random_string" "app_name_autogen" {
  length  = 6
  special = false
}

locals {

  # Extract k8s version without the 'v' prefix
  cluster_k8s_version_no_v = replace(oci_containerengine_cluster.oke_cluster[0].kubernetes_version, "v", "")

  all_shape_compatible_images   = data.oci_core_images.shape_specific_images.images
  all_cluster_compatible_images = data.oci_containerengine_node_pool_option.cluster_node_pool_option.sources

  all_shape_compatible_image_ids = [for image in local.all_shape_compatible_images : image.id]

  all_cluster_compatible_image_ids = [for source in local.all_cluster_compatible_images : source.image_id]

  first_compatible_image_id = tolist(setintersection(toset(local.all_shape_compatible_image_ids), toset(local.all_cluster_compatible_image_ids)))[0]

}

# Debug outputs
output "debug_cluster_k8s_version_no_v" {
  value = local.cluster_k8s_version_no_v
}

output "debug_all_shape_compatible_images" {
  value = local.all_shape_compatible_images
}

output "debug_all_cluster_compatible_images" {
  value = local.all_cluster_compatible_images
}

output "debug_first_compatible_image_id" {
  value = local.first_compatible_image_id
}
