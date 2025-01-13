# Copyright (c) 2025, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.compartment_ocid
}

data "oci_containerengine_cluster_kube_config" "oke_special" {
  cluster_id = var.existent_oke_cluster_id
}

data "kubernetes_service" "ingress_nginx_controller_service" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "cluster-tools"
  }
  depends_on = [module.oke-quickstart.helm_release_ingress_nginx]
  count = var.ingress_nginx_enabled ? 1 : 0
}

data "kubernetes_secret" "grafana_password" {
  metadata {
    name      = "grafana"
    namespace = "cluster-tools"
  }
  depends_on = [module.oke-quickstart.helm_release_grafana]
  count = var.grafana_enabled ? 1 : 0
}

