# Copyright (c) 2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

output "comments" {
  value = "The application URL will be unavailable for a few minutes after provisioning while the application is configured and deployed to Kubernetes"
}
output "deployed_oke_kubernetes_version" {
  value = local.deployed_k8s_version
}
output "deployed_to_region" {
  value = var.region
}
output "dev" {
  value = "Made with \u2764 by Oracle Developers"
}
output "kubeconfig" {
  value = data.oci_containerengine_cluster_kube_config.oke.content
}
output "kubeconfig_for_kubectl" {
  value       = "export KUBECONFIG=${path.root}/generated/kubeconfig"
  description = "If using Terraform locally, this command set KUBECONFIG environment variable to run kubectl locally"
}
output "orm_private_endpoint_oke_api_ip_address" {
  value       = (var.cluster_endpoint_visibility == "Private") ? data.oci_resourcemanager_private_endpoint_reachable_ip.private_kubernetes_endpoint.0.ip_address : ""
  description = "OCI Resource Manager Private Endpoint ip address for OKE Kubernetes API Private Endpoint"

  depends_on = [
    oci_resourcemanager_private_endpoint.private_kubernetes_endpoint
  ]
}

# OKE info
output "oke_cluster_ocid" {
  value       = var.create_new_oke_cluster ? oci_containerengine_cluster.oke_cluster[0].id : ""
  description = "OKE Cluster OCID"
}
output "oke_cluster_compartment_ocid" {
  value       = local.oke_compartment_ocid
  description = "Compartment OCID used by the OKE Cluster"
}
