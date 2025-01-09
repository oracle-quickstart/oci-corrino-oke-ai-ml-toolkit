# Copyright (c) 2025, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

resource "kubernetes_service" "corrino_portal_service" {
  metadata {
    name = "corrino-portal"
    annotations = {
      "oci.oraclecloud.com/load-balancer-type"            = "lb"
      "service.beta.kubernetes.io/oci-load-balancer-shape"= "flexible"
    }
  }
  spec {
    selector = {
      app = "corrino-portal"
    }
    port {
      port        = 80
      target_port = 3000
    }
  }
  depends_on = [kubernetes_deployment.corrino_portal_deployment]
}

resource "kubernetes_deployment" "corrino_portal_deployment" {
  metadata {
    name      = "corrino-portal"
    labels    = {
      app = "corrino-portal"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "corrino-portal"
      }
    }
    template {
      metadata {
        labels = {
          app = "corrino-portal"
        }
      }
      spec {
        container {
          name  = "corrino-portal"
          image = local.app.frontend_image_uri
          image_pull_policy = "Always"

          dynamic "env" {
            for_each = local.env_universal
            content {
              name  = env.value.name
              value = env.value.value
            }
          }

          dynamic "env" {
            for_each = local.env_app_configmap
            content {
              name = env.value.name
              value_from {
                config_map_key_ref {
                  name = env.value.config_map_name
                  key  = env.value.config_map_key
                }
              }
            }
          }
        }
      }
    }
  }
  depends_on = [kubernetes_deployment.corrino_cp_deployment]
}

