# Copyright (c) 2021, 2022, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

resource "oci_containerengine_cluster" "oke_cluster" {
  compartment_id     = local.oke_compartment_ocid
  kubernetes_version = (var.k8s_version == "Latest") ? local.cluster_k8s_latest_version : var.k8s_version
  name               = "${local.app_name} (${local.deploy_id})"
  vcn_id             = var.vcn_id
  kms_key_id         = var.oci_vault_key_id_oke_secrets != "" ? var.oci_vault_key_id_oke_secrets : null
  # type               = var.cluster_type
  freeform_tags = var.cluster_tags.freeformTags
  defined_tags  = var.cluster_tags.definedTags

  endpoint_config {
    is_public_ip_enabled = (var.cluster_endpoint_visibility == "Private") ? false : true
    subnet_id            = var.k8s_endpoint_subnet_id
    nsg_ids              = []
  }
  options {
    service_lb_subnet_ids = [var.lb_subnet_id]
    add_ons {
      is_kubernetes_dashboard_enabled = var.cluster_options_add_ons_is_kubernetes_dashboard_enabled
      is_tiller_enabled               = false # Default is false, left here for reference
    }
    admission_controller_options {
      is_pod_security_policy_enabled = var.cluster_options_admission_controller_options_is_pod_security_policy_enabled
    }
    kubernetes_network_config {
      services_cidr = lookup(var.network_cidrs, "KUBERNETES-SERVICE-CIDR")
      pods_cidr     = lookup(var.network_cidrs, "PODS-CIDR")
    }
    persistent_volume_config {
      freeform_tags = var.block_volumes_tags.freeformTags
      # defined_tags  = var.block_volumes_tags.definedTags
    }
    service_lb_config {
      freeform_tags = var.load_balancers_tags.freeformTags
      # defined_tags  = var.load_balancers_tags.definedTags
    }
  }
  image_policy_config {
    is_policy_enabled = false
    # key_details {
    #   # kms_key_id = var.oci_vault_key_id_oke_image_policy != "" ? var.oci_vault_key_id_oke_image_policy : null
    # }
  }
  cluster_pod_network_options {
    cni_type = var.cni_type
  }

  lifecycle {
    ignore_changes = [freeform_tags, defined_tags, kubernetes_version, id]
  }

  count = var.create_new_oke_cluster ? 1 : 0
}

# Local kubeconfig for when using Terraform locally. Not used by Oracle Resource Manager
resource "local_file" "oke_kubeconfig" {
  content         = data.oci_containerengine_cluster_kube_config.oke.content
  filename        = "${path.root}/generated/kubeconfig"
  file_permission = "0644"
}

# Get OKE options
locals {
  cluster_k8s_latest_version = reverse(sort(data.oci_containerengine_cluster_option.oke.kubernetes_versions))[0]
  deployed_k8s_version = var.create_new_oke_cluster ? ((var.k8s_version == "Latest") ? local.cluster_k8s_latest_version : var.k8s_version) : [
  for x in data.oci_containerengine_clusters.oke.clusters : x.kubernetes_version if x.id == var.existent_oke_cluster_id][0]
}
