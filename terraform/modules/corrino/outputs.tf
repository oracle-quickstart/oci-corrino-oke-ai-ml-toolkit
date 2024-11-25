# Copyright (c) 2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# Deployment outputs
output "stack_version" {
  value = file("${path.module}/VERSION")
}
output "deploy_id" {
  value = local.deploy_id
}

# OKE Outputs
output "comments" {
  value = module.oke.comments
}
output "deployed_oke_kubernetes_version" {
  value = module.oke.deployed_oke_kubernetes_version
}
output "deployed_to_region" {
  value = module.oke.deployed_to_region
}
output "kubeconfig" {
  value     = module.oke.kubeconfig
  sensitive = true
}
output "kubeconfig_for_kubectl" {
  value       = module.oke.kubeconfig_for_kubectl
  description = "If using Terraform locally, this command set KUBECONFIG environment variable to run kubectl locally"
}
output "oke_cluster_ocid" {
  value = module.oke.oke_cluster_ocid
}
output "oke_node_pools" {
  value = module.oke_node_pools
}
output "subnets" {
  value = module.subnets
}

output "dev" {
  value = module.oke.dev
}
### Important Security Notice ###
# The private key generated by this resource will be stored unencrypted in your Terraform state file. 
# Use of this resource for production deployments is not recommended. 
# Instead, generate a private key file outside of Terraform and distribute it securely to the system where Terraform will be run.
output "generated_private_key_pem" {
  value     = var.generate_public_ssh_key ? tls_private_key.oke_worker_node_ssh_key.private_key_pem : "No Keys Auto Generated"
  sensitive = true
}

output "cluster_tools_namespace" {
  value = module.cluster-tools.cluster_tools_namespace
}

output "helm_release_ingress_nginx" {
   value = module.cluster-tools.helm_release_ingress_nginx
}

output "helm_release_grafana" {
   value = module.cluster-tools.helm_release_grafana
}