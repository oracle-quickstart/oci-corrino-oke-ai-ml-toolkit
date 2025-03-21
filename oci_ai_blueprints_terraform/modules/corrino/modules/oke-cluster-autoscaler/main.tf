# Copyright (c) 2021, 2022, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

locals {
  cluster_autoscaler_supported_k8s_versions           = var.cluster_autoscaler_supported_k8s_versions # There's no API to get that list. Need to be updated manually
  cluster_autoscaler_image_version                    = lookup(local.cluster_autoscaler_supported_k8s_versions, local.k8s_major_minor_version, reverse(values(local.cluster_autoscaler_supported_k8s_versions))[0])
  cluster_autoscaler_default_region                   = "us-ashburn-1"
  cluster_autoscaler_image_regions                    = ["us-ashburn-1", "us-phoenix-1", "uk-london-1", "eu-frankfurt-1"]
  cluster_autoscaler_image_region                     = contains(local.cluster_autoscaler_image_regions, var.region) ? var.region : local.cluster_autoscaler_default_region
  cluster_autoscaler_image                            = var.custom_cluster_autoscaler_image != "" ? var.custom_cluster_autoscaler_image : "${local.cluster_autoscaler_image_region}.ocir.io/oracle/oci-cluster-autoscaler:${local.cluster_autoscaler_image_version}"
  cluster_autoscaler_log_level_verbosity              = var.cluster_autoscaler_log_level_verbosity
  cluster_autoscaler_node_pools                       = [for map in var.oke_node_pools[*] : "--nodes=${map.node_pool_min_nodes}:${map.node_pool_max_nodes}:${map.node_pool_id}"]
  cluster_autoscaler_max_node_provision_time          = var.cluster_autoscaler_max_node_provision_time
  cluster_autoscaler_scale_down_delay_after_add       = var.cluster_autoscaler_scale_down_delay_after_add
  cluster_autoscaler_scale_down_unneeded_time         = var.cluster_autoscaler_scale_down_unneeded_time
  cluster_autoscaler_unremovable_node_recheck_timeout = var.cluster_autoscaler_unremovable_node_recheck_timeout
  cluster_autoscaler_enabled                          = alltrue([contains(keys(local.cluster_autoscaler_supported_k8s_versions), local.k8s_major_minor_version)]) ? anytrue(var.oke_node_pools[*].node_pool_autoscaler_enabled) : false
  cluster_autoscaler_cloud_provider                   = local.k8s_major_minor_version < "1.24" ? "oci" : "oci-oke"
  k8s_major_minor_version                             = regex("\\d+(?:\\.(?:\\d+|x)(?:))", try(var.oke_node_pools.0.node_k8s_version, "1.0"))
}

# NOTE: Service Account Terraform resource is not supported with Kubernetes 1.24.
resource "kubernetes_service_account_v1" "cluster_autoscaler_sa" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    labels = {
      k8s-addon = "cluster-autoscaler.addons.k8s.io"
      k8s-app   = "cluster-autoscaler"
    }
  }
  automount_service_account_token = true # false

  count = local.cluster_autoscaler_enabled ? 1 : 0
}
# resource "kubernetes_secret" "cluster_autoscaler_sa_secret" {
#   metadata {
#     name      = "cluster-autoscaler-token-secret"
#     namespace = "kube-system"
#     annotations = {
#       "kubernetes.io/service-account.name"      = "cluster-autoscaler"
#       "kubernetes.io/service-account.namespace" = "kube-system"
#     }
#   }
#   type = "kubernetes.io/service-account-token"

#   depends_on = [kubernetes_service_account.cluster_autoscaler_sa]

#   count = local.cluster_autoscaler_enabled ? 1 : 0
# }
resource "kubernetes_cluster_role" "cluster_autoscaler_cr" {
  metadata {
    name = "cluster-autoscaler"
    labels = {
      k8s-addon = "cluster-autoscaler.addons.k8s.io"
      k8s-app   = "cluster-autoscaler"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["events", "endpoints"]
    verbs      = ["create", "patch"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/eviction"]
    verbs      = ["create"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/status"]
    verbs      = ["update"]
  }
  rule {
    api_groups     = [""]
    resource_names = ["cluster-autoscaler"]
    resources      = ["endpoints"]
    verbs          = ["get", "update"]
  }
  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["watch", "list", "get", "patch", "update"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods", "services", "replicationcontrollers", "persistentvolumeclaims", "persistentvolumes", "namespaces"]
    verbs      = ["watch", "list", "get"]
  }
  rule {
    api_groups = ["extensions"]
    resources  = ["replicasets", "daemonsets"]
    verbs      = ["watch", "list", "get"]
  }
  rule {
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
    verbs      = ["watch", "list"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["statefulsets", "replicasets", "daemonsets"]
    verbs      = ["watch", "list", "get"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses", "csinodes", "csidrivers", "csistoragecapacities"]
    verbs      = ["watch", "list", "get"]
  }
  rule {
    api_groups = ["batch", "extensions"]
    resources  = ["jobs"]
    verbs      = ["get", "list", "watch", "patch"]
  }
  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["create"]
  }
  rule {
    api_groups     = ["coordination.k8s.io"]
    resource_names = ["cluster-autoscaler"]
    resources      = ["leases"]
    verbs          = ["get", "update"]
  }

  count = local.cluster_autoscaler_enabled ? 1 : 0
}
resource "kubernetes_role" "cluster_autoscaler_role" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    labels = {
      k8s-addon = "cluster-autoscaler.addons.k8s.io"
      k8s-app   = "cluster-autoscaler"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["create", "list", "watch"]
  }
  rule {
    api_groups     = [""]
    resource_names = ["cluster-autoscaler-status", "cluster-autoscaler-priority-expander"]
    resources      = ["configmaps"]
    verbs          = ["delete", "get", "update", "watch"]
  }

  count = local.cluster_autoscaler_enabled ? 1 : 0
}
resource "kubernetes_cluster_role_binding" "cluster_autoscaler_crb" {
  metadata {
    name = "cluster-autoscaler"
    labels = {
      k8s-addon = "cluster-autoscaler.addons.k8s.io"
      k8s-app   = "cluster-autoscaler"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-autoscaler"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cluster-autoscaler"
    namespace = "kube-system"
  }

  count = local.cluster_autoscaler_enabled ? 1 : 0
}
resource "kubernetes_role_binding" "cluster_autoscaler_rb" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    labels = {
      k8s-addon = "cluster-autoscaler.addons.k8s.io"
      k8s-app   = "cluster-autoscaler"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "cluster-autoscaler"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cluster-autoscaler"
    namespace = "kube-system"
  }

  count = local.cluster_autoscaler_enabled ? 1 : 0
}
resource "kubernetes_deployment" "cluster_autoscaler_deployment" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    labels = {
      app = "cluster-autoscaler"
    }
  }

  spec {
    replicas = var.cluster_autoscaler_num_of_replicas

    selector {
      match_labels = {
        app = "cluster-autoscaler"
      }
    }

    template {
      metadata {
        labels = {
          app = "cluster-autoscaler"
        }
        annotations = {
          "prometheus.io/scrape" = true
          "prometheus.io/port"   = 8085
        }
      }

      spec {
        service_account_name = "cluster-autoscaler"

        container {
          image = local.cluster_autoscaler_image
          name  = "cluster-autoscaler"

          resources {
            limits = {
              cpu    = "100m"
              memory = "300Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "300Mi"
            }
          }
          command = concat([
            "./cluster-autoscaler",
            "--v=${local.cluster_autoscaler_log_level_verbosity}",
            "--stderrthreshold=info",
            "--cloud-provider=${local.cluster_autoscaler_cloud_provider}",
            "--max-node-provision-time=${local.cluster_autoscaler_max_node_provision_time}",
            "--scale-down-delay-after-add=${local.cluster_autoscaler_scale_down_delay_after_add}",
            "--scale-down-unneeded-time=${local.cluster_autoscaler_scale_down_unneeded_time}",
            "--unremovable-node-recheck-timeout=${local.cluster_autoscaler_unremovable_node_recheck_timeout}",
            "--balance-similar-node-groups",
            "--balancing-ignore-label=displayName",
            "--balancing-ignore-label=hostname",
            "--balancing-ignore-label=internal_addr",
            "--balancing-ignore-label=oci.oraclecloud.com/fault-domain"
            ],
            local.cluster_autoscaler_node_pools,
          var.cluster_autoscaler_extra_args)
          image_pull_policy = "Always"
          env {
            name  = "OKE_USE_INSTANCE_PRINCIPAL"
            value = "true"
          }
          env {
            name  = "OCI_SDK_APPEND_USER_AGENT"
            value = "oci-oke-cluster-autoscaler"
          }
        }
      }
    }
  }

  wait_for_rollout = false

  count = local.cluster_autoscaler_enabled ? 1 : 0
}
