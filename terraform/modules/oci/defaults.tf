# Copyright (c) 2022-2023 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# File Version: 0.1.0

# Dependencies:
#   - terraform-oci-networking module

################################################################################
# If you have extra configurations to add, you can add them here.
# It's supported to include:
#   - Extra Node Pools and their configurations
#   - Extra subnets
#   - Extra route tables and security lists
################################################################################

################################################################################
# Deployment Defaults
################################################################################
locals {
#  deploy_id   = random_string.deploy_id.result
  deploy_id   = var.deploy_id
  deploy_tags = { "DeploymentID" = local.deploy_id, "AppName" = local.app_name, "Quickstart" = "terraform-oci-oke-quickstart", "OKEclusterName" = "${local.app_name} (${local.deploy_id})" }
  oci_tag_values = {
    "freeformTags" = merge(var.tag_values.freeformTags, local.deploy_tags),
    "definedTags"  = var.tag_values.definedTags
  }
  app_name            = var.app_name
  app_name_normalized = substr(replace(lower(local.app_name), " ", "-"), 0, 6)
  app_name_for_dns    = substr(lower(replace(local.app_name, "/\\W|_|\\s/", "")), 0, 6)
}

#resource "random_string" "deploy_id" {
#  length  = 4
#  special = false
#}

################################################################################
# Required locals for the oci-networking and oke modules
################################################################################
locals {
  node_pools                    = concat(local.node_pool_1, local.extra_node_pools, var.extra_node_pools)
  create_new_vcn                = (var.create_new_oke_cluster && var.create_new_vcn) ? true : false
  vcn_display_name              = "[${local.app_name}] VCN for OKE (${local.deploy_id})"
  create_subnets                = (var.create_subnets) ? true : false
  subnets                       = concat(local.subnets_oke, local.extra_subnets, var.extra_subnets)
  route_tables                  = concat(local.route_tables_oke, var.extra_route_tables)
  security_lists                = concat(local.security_lists_oke, var.extra_security_lists)
  resolved_vcn_compartment_ocid = (var.create_new_compartment_for_oke ? local.oke_compartment_ocid : var.compartment_ocid)
  pre_vcn_cidr_blocks           = split(",", var.vcn_cidr_blocks)
  vcn_cidr_blocks               = contains(module.vcn.cidr_blocks, local.pre_vcn_cidr_blocks[0]) ? distinct(concat([local.pre_vcn_cidr_blocks[0]], module.vcn.cidr_blocks)) : module.vcn.cidr_blocks
  network_cidrs = {
    VCN-MAIN-CIDR                                  = local.vcn_cidr_blocks[0]                     # e.g.: "10.20.0.0/16" = 65536 usable IPs
    ENDPOINT-REGIONAL-SUBNET-CIDR                  = cidrsubnet(local.vcn_cidr_blocks[0], 12, 0)  # e.g.: "10.20.0.0/28" = 15 usable IPs
    NODES-REGIONAL-SUBNET-CIDR                     = cidrsubnet(local.vcn_cidr_blocks[0], 6, 3)   # e.g.: "10.20.12.0/22" = 1021 usable IPs (10.20.12.0 - 10.20.15.255)
    LB-REGIONAL-SUBNET-CIDR                        = cidrsubnet(local.vcn_cidr_blocks[0], 6, 4)   # e.g.: "10.20.16.0/22" = 1021 usable IPs (10.20.16.0 - 10.20.19.255)
    FSS-MOUNT-TARGETS-REGIONAL-SUBNET-CIDR         = cidrsubnet(local.vcn_cidr_blocks[0], 10, 81) # e.g.: "10.20.20.64/26" = 62 usable IPs (10.20.20.64 - 10.20.20.255)
    APIGW-FN-REGIONAL-SUBNET-CIDR                  = cidrsubnet(local.vcn_cidr_blocks[0], 8, 30)  # e.g.: "10.20.30.0/24" = 254 usable IPs (10.20.30.0 - 10.20.30.255)
    VCN-NATIVE-POD-NETWORKING-REGIONAL-SUBNET-CIDR = cidrsubnet(local.vcn_cidr_blocks[0], 1, 1)   # e.g.: "10.20.128.0/17" = 32766 usable IPs (10.20.128.0 - 10.20.255.255)
    BASTION-REGIONAL-SUBNET-CIDR                   = cidrsubnet(local.vcn_cidr_blocks[0], 12, 32) # e.g.: "10.20.2.0/28" = 15 usable IPs (10.20.2.0 - 10.20.2.15)
    PODS-CIDR                                      = "10.244.0.0/16"
    KUBERNETES-SERVICE-CIDR                        = "10.96.0.0/16"
    ALL-CIDR                                       = "0.0.0.0/0"
  }
}

################################################################################
# Extra OKE node pools
# Example commented out below
################################################################################
locals {
  extra_node_pools = [
    # {
    #   node_pool_name                            = "GPU" # Must be unique
    #   node_pool_autoscaler_enabled            = false
    #   node_pool_min_nodes                       = 1
    #   node_pool_max_nodes                       = 2
    #   node_k8s_version                          = var.k8s_version
    #   node_pool_shape                           = "BM.GPU.A10.4"
    #   node_pool_shape_specific_ad                = 3 # Optional, if not provided or set = 0, will be randomly assigned
    #   node_pool_node_shape_config_ocpus         = 1
    #   node_pool_node_shape_config_memory_in_gbs = 1
    #   node_pool_boot_volume_size_in_gbs         = "100"
    #   existent_oke_nodepool_id_for_autoscaler   = null
    #   node_pool_alternative_subnet              = null # Optional, name of previously created subnet
    #   image_operating_system                    = null
    #   image_operating_system_version            = null
    #   extra_initial_node_labels                 = [{ key = "app.pixel/gpu", value = "true" }]
    #   cni_type                                  = "FLANNEL_OVERLAY" # "FLANNEL_OVERLAY" or "OCI_VCN_IP_NATIVE"
    # },
  ]
}

locals {
  extra_subnets = [
    # {
    #   subnet_name                = "opensearch_subnet"
    #   cidr_block                 = cidrsubnet(local.vcn_cidr_blocks[0], 8, 35) # e.g.: "10.20.35.0/24" = 254 usable IPs (10.20.35.0 - 10.20.35.255)
    #   display_name               = "OCI OpenSearch Service subnet (${local.deploy_id})" # If null, is autogenerated
    #   dns_label                  = "opensearch${local.deploy_id}" # If null, disable dns label
    #   prohibit_public_ip_on_vnic = false
    #   prohibit_internet_ingress  = false
    #   route_table_id             = module.route_tables["public"].route_table_id # If null, the VCN's default route table is used
    #   alternative_route_table_name    = null # Optional, Name of the previously created route table
    #   dhcp_options_id            = module.vcn.default_dhcp_options_id # If null, the VCN's default set of DHCP options is used
    #   security_list_ids          = [module.security_lists["opensearch_security_list"].security_list_id] # If null, the VCN's default security list is used
    #   extra_security_list_names  = [] # Optional, Names of the previously created security lists
    #   ipv6cidr_block             = null # If null, no IPv6 CIDR block is assigned
    # },
  ]
}