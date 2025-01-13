# Copyright (c) 2025, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

output "external_ip" {
  value = local.network.external_ip
}

output "corrino_source_code" {
  value = "https://github.com/oracle-quickstart/corrino/"
}
output "corrino_version" {
  value = local.versions.corrino_version
}

output "corrino_api_url" {
  value       = format("https://${local.public_endpoint.api}")
  description = "API Service"
  depends_on = [module.oke-quickstart.helm_release_ingress_nginx]
}

output "corrino_portal_url" {
  value       = format("https://${local.public_endpoint.portal}")
  description = "Portal Service"
  depends_on = [module.oke-quickstart.helm_release_ingress_nginx]
}

output "corrino_grafana_url" {
  value       = var.grafana_enabled ? format("https://${local.public_endpoint.grafana}") : null
  description = "Grafana Service"
  depends_on = [module.oke-quickstart.helm_release_ingress_nginx]
}

output "grafana_admin_username" {
  value = "admin"
}

output "grafana_admin_password" {
  value = module.oke-quickstart.grafana_admin_password
}

output "corrino_prometheus_url" {
  value       = var.prometheus_enabled ? format("https://${local.public_endpoint.prometheus}") : null
  description = "Prometheus Service"
  depends_on = [module.oke-quickstart.helm_release_ingress_nginx]
}

output "corrino_mlflow_url" {
  value       = var.mlflow_enabled ? format("https://${local.public_endpoint.mlflow}") : null
  description = "MLflow Service"
  depends_on = [module.oke-quickstart.helm_release_ingress_nginx]
}

output "autonomous_database_password" {
  value = random_string.autonomous_database_admin_password.result
}