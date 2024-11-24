# Copyright (c) 2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# Deployment outputs
output "deploy_id" {
  value = module.oke-quickstart.deploy_id
}

## Deployment tags
#output "deploy_tags" {
#  value = module.oke-quickstart.deploy_tags
#}

## OKE Cluster name
#output "oke_cluster_name" {
#  value = module.oke-quickstart.deploy_tags
#}


# OKE Outputs
#output "comments" {
#  value = module.oke-quickstart.comments
#}

#output "deployed_oke_kubernetes_version" {
#  value = module.oke-quickstart.deployed_oke_kubernetes_version
#}

output "deployed_to_region" {
  value = module.oke-quickstart.deployed_to_region
}

output "kubeconfig" {
  value     = module.oke-quickstart.kubeconfig
  sensitive = true
}

output "kubeconfig_for_kubectl" {
  value       = module.oke-quickstart.kubeconfig_for_kubectl
  description = "If using Terraform locally, this command set KUBECONFIG environment variable to run kubectl locally"
}

#output "dev" {
#  value = module.oke-quickstart.dev
#}
### Important Security Notice ###
# The private key generated by this resource will be stored unencrypted in your Terraform state file. 
# Use of this resource for production deployments is not recommended. 
# Instead, generate a private key file outside of Terraform and distribute it securely to the system where Terraform will be run.

output "generated_private_key_pem" {
  value     = module.oke-quickstart.generated_private_key_pem
  sensitive = true
}

output "oke_cluster_ocid" {
  value = module.oke-quickstart.oke_cluster_ocid
}

output "oke_node_pools" {
  value = module.oke-quickstart.oke_node_pools
}

output "oke_subnets" {
  value = module.oke-quickstart.subnets
}

output "oke_nodes_subnet_id" {
  value = module.oke-quickstart.subnets["oke_nodes_subnet"]["subnet_id"]
}

output "oke_nodes_subnet" {
  value = module.oke-quickstart.subnets["oke_nodes_subnet"]
}

output "cluster_endpoint" {
  value = local.cluster_endpoint
  sensitive = false
}

output "cluster_ca_certificate" {
  value = local.cluster_ca_certificate
  sensitive = false
}

#output "cluster_id" {
#  value = local.cluster_id
#  sensitive = false
#}

output "cluster_region" {
  value = local.cluster_region
  sensitive = false
}

output "external_ip" {
  value = local.external_ip

  depends_on = [kubernetes_ingress_v1.corrino_cp_ingress]
}

output "corrino_source_code" {
  value = "https://github.com/oracle-quickstart/corrino/"
}
output "corrino_version" {
  value = file("${path.module}/VERSION")
}

# ----------------------------------------
# Public endpoints
# ----------------------------------------

output "api_url" {
  value       = local.public_endpoint.api
  description = "API Service"
  depends_on = [module.oke-quickstart.helm_release_ingress_nginx]
}

output "portal_url" {
  value       = local.public_endpoint.portal
  description = "Portal Service"
  depends_on = [module.oke-quickstart.helm_release_ingress_nginx]
}

output "grafana_url" {
  value       = var.grafana_enabled ? local.public_endpoint.grafana : null
  description = "Grafana Service"
  depends_on = [module.oke-quickstart.helm_release_ingress_nginx]
}

output "prometheus_url" {
  value       = var.prometheus_enabled ? local.public_endpoint.prometheus : null
  description = "Prometheus Service"
  depends_on = [module.oke-quickstart.helm_release_ingress_nginx]
}

output "mlflow_url" {
  value       = var.mlflow_enabled ? local.public_endpoint.mlflow : null
  description = "MLflow Service"
  depends_on = [module.oke-quickstart.helm_release_ingress_nginx]
}

