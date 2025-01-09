# Copyright (c) 2022, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# File Version: 0.7.1

resource "oci_containerengine_node_pool" "oke_node_pool" {
  cluster_id         = var.oke_cluster_ocid
  compartment_id     = var.oke_cluster_compartment_ocid
  kubernetes_version = local.node_k8s_version
  name               = var.node_pool_name
  node_shape         = var.node_pool_shape
  ssh_public_key     = var.public_ssh_key
  freeform_tags      = var.node_pools_tags.freeformTags
  defined_tags       = var.node_pools_tags.definedTags

  node_config_details {
    dynamic "placement_configs" {
      for_each = local.node_pool_ads # data.oci_identity_availability_domains.ADs.availability_domains

      content {
        availability_domain = placement_configs.value.name
        subnet_id           = var.nodes_subnet_id
      }
    }
    node_pool_pod_network_option_details {
      cni_type          = var.cni_type
      max_pods_per_node = 31
      pod_nsg_ids       = []
      pod_subnet_ids    = [var.vcn_native_pod_networking_subnet_ocid]
    }
    # nsg_ids       = []
    size          = var.node_pool_min_nodes
    kms_key_id    = var.oci_vault_key_id_oke_node_boot_volume != "" ? var.oci_vault_key_id_oke_node_boot_volume : null
    freeform_tags = var.worker_nodes_tags.freeformTags
    defined_tags  = var.worker_nodes_tags.definedTags
  }

  dynamic "node_shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      ocpus         = var.node_pool_node_shape_config_ocpus
      memory_in_gbs = var.node_pool_node_shape_config_memory_in_gbs
    }
  }

  node_source_details {
    source_type             = "IMAGE"
    image_id                = lookup(data.oci_core_images.node_pool_images.images[0], "id")
    boot_volume_size_in_gbs = var.node_pool_boot_volume_size_in_gbs
  }
  # node_eviction_node_pool_settings {
  #   eviction_grace_duration              = "PT1H"
  #   is_force_delete_after_grace_duration = false
  # }
  node_metadata = {
    user_data = anytrue([var.node_pool_oke_init_params != "", var.node_pool_cloud_init_parts != []]) ? data.cloudinit_config.nodes.rendered : null
  }

  initial_node_labels {
    key   = "name"
    value = var.node_pool_name
  }

  dynamic "initial_node_labels" {
    for_each = var.extra_initial_node_labels

    content {
      key   = initial_node_labels.value.key
      value = initial_node_labels.value.value
    }
  }

  lifecycle {
    ignore_changes = [
      node_config_details.0.size
    ]
  }

  count = var.create_new_node_pool ? 1 : 0
}

locals {
  # Checks if is using Flexible Compute Shapes
  is_flexible_node_shape = contains(split(".", var.node_pool_shape), "Flex")

  # Gets the latest Kubernetes version supported by the node pool
  node_pool_k8s_latest_version = reverse(sort(data.oci_containerengine_node_pool_option.node_pool.kubernetes_versions))[0]
  node_k8s_version             = (var.node_k8s_version == "Latest") ? local.node_pool_k8s_latest_version : var.node_k8s_version

  # Get ADs for the shape to be used on the node pool
  node_pool_ads = (var.node_pool_shape_specific_ad > 0) ? data.oci_identity_availability_domain.specfic : data.oci_identity_availability_domains.ADs.availability_domains
}
