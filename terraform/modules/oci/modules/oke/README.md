# Terraform OKE Submodule

This module deploys an OKE Kubernetes cluster.

## Usage

```hcl
module "oke" {
  source = "./modules/oke"

  providers = {
    oci             = oci
    oci.home_region = oci.home_region
  }

  # Oracle Cloud Infrastructure Tenancy and Compartment OCID
  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = local.oke_compartment_ocid
  region           = var.region

  # Deployment Tags + Freeform Tags + Defined Tags
  cluster_tags        = local.oci_tag_values
  load_balancers_tags = local.oci_tag_values
  block_volumes_tags  = local.oci_tag_values

  # OKE Cluster
  ## create_new_oke_cluster
  create_new_oke_cluster  = var.create_new_oke_cluster
  existent_oke_cluster_id = var.existent_oke_cluster_id

  ## Network Details
  vcn_id                 = module.vcn.vcn_id
  network_cidrs          = local.network_cidrs
  k8s_endpoint_subnet_id = local.create_subnets ? module.subnets["oke_k8s_endpoint_subnet"].subnet_id : var.existent_oke_k8s_endpoint_subnet_ocid
  lb_subnet_id           = local.create_subnets ? module.subnets["oke_lb_subnet"].subnet_id : var.existent_oke_load_balancer_subnet_ocid
  cni_type               = local.cni_type
  ### Cluster Workers visibility
  cluster_workers_visibility = var.cluster_workers_visibility
  ### Cluster API Endpoint visibility
  cluster_endpoint_visibility = var.cluster_endpoint_visibility

  ## Control Plane Kubernetes Version
  k8s_version = var.k8s_version

  ## Create Dynamic group and Policies for Autoscaler and OCI Metrics and Logging
  create_dynamic_group_for_nodes_in_compartment = var.create_dynamic_group_for_nodes_in_compartment
  create_compartment_policies                   = var.create_compartment_policies

  ## Encryption (OCI Vault/Key Management/KMS)
  oci_vault_key_id_oke_secrets      = module.vault.oci_vault_key_id
  oci_vault_key_id_oke_image_policy = module.vault.oci_vault_key_id
}
```
