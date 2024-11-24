# Copyright (c) 2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# Gets supported Kubernetes versions for node pools
data "oci_containerengine_node_pool_option" "node_pool" {
  node_pool_option_id = "all"
}

# Gets a list of supported images based on the shape, operating_system and operating_system_version provided
data "oci_core_images" "node_pool_images" {
  compartment_id           = var.oke_cluster_compartment_ocid
  operating_system         = var.image_operating_system
  operating_system_version = var.image_operating_system_version
  shape                    = var.node_pool_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}
# Gets a specfic Availability Domain
data "oci_identity_availability_domain" "specfic" {
  compartment_id = var.tenancy_ocid
  ad_number      = var.node_pool_shape_specific_ad

  count = (var.node_pool_shape_specific_ad > 0) ? 1 : 0
}

# Prepare Cloud Unit for Node Pool nodes
data "cloudinit_config" "nodes" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = <<EOF
#!/bin/bash
curl --fail -H "Authorization: Bearer Oracle" -L0 http://169.254.169.254/opc/v2/instance/metadata/oke_init_script | base64 --decode >/var/run/oke-init.sh
bash /var/run/oke-init.sh ${var.node_pool_oke_init_params}
EOF
  }

  dynamic "part" {
    for_each = var.node_pool_cloud_init_parts
    content {
      content_type = part.value["content_type"]
      content      = part.value["content"]
      filename     = part.value["filename"]
    }
  }
}