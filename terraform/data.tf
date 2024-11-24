

data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.compartment_ocid
}

data "oci_containerengine_cluster_kube_config" "oke_special" {
  cluster_id = var.existent_oke_cluster_id
}

data "kubernetes_ingress" "corrino_cp_ingress" {
  metadata {
    name      = local.app.backend_service_name_ingress
  }
}
