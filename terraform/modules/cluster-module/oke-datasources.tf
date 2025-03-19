# Copyright (c) 2020-2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# data "oci_core_image_shapes" "test_image_shapes" {
#     #Required
#     image_id = oci_core_image.test_image.id
# }

# Gets a list of supported images based on the shape, operating_system and operating_system_version provided
data "oci_core_images" "node_pool_images" {
  compartment_id   = local.oke_compartment_ocid
  operating_system = var.image_operating_system
  shape            = var.node_pool_instance_shape.instanceShape
  sort_by          = "TIMECREATED"
  sort_order       = "DESC"
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

  # Map of available OKE-specific images from node_pool_option
  available_images = {
    for src in data.oci_containerengine_node_pool_option.cluster_node_pool_option.sources :
    src.image_id => src.source_name
  }

  # Find images that match the k8s version (strict matching)
  k8s_version_strict_match_images = {
    for id, name in local.available_images :
    id => name
    if strcontains(name, "-OKE-${local.cluster_k8s_version_no_v}-")
  }

  # Find images that just contain the k8s version number
  k8s_version_loose_match_images = {
    for id, name in local.available_images :
    id => name
    if strcontains(name, local.cluster_k8s_version_no_v)
  }

  # Get the first compatible image id
  first_compatible_image_id = try(
    keys(local.k8s_version_strict_match_images)[0],
    try(
      keys(local.k8s_version_loose_match_images)[0],
      try(
        keys(local.available_images)[0],
        null
      )
    )
  )
}

# Debug outputs
output "debug_cluster_k8s_version_no_v" {
  value = local.cluster_k8s_version_no_v
}

output "debug_available_images" {
  value = local.available_images
}

output "debug_first_compatible_image_id" {
  value = local.first_compatible_image_id
}

output "debug_k8s_version_strict_match_images" {
  value       = local.k8s_version_strict_match_images
  description = "Images that exactly match the k8s version pattern"
}

output "debug_k8s_version_loose_match_images" {
  value       = local.k8s_version_loose_match_images
  description = "Images that contain the k8s version number"
}

output "debug_image_selection_explanation" {
  value = try(
    length(local.k8s_version_strict_match_images) > 0
    ? "Found image matching k8s version (strict matching)"
    : length(local.k8s_version_loose_match_images) > 0
    ? "Found image matching k8s version (loose matching)"
    : length(local.available_images) > 0
    ? "Using fallback: any available image"
    : "No images available"
  , "No images available")
}

output "debug_node_pool_images" {
  value = data.oci_core_images.node_pool_images
}

output "debug_node_pool_option" {
  value = data.oci_containerengine_node_pool_option.cluster_node_pool_option
}