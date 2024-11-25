locals {

  app = {
    backend_service_name                         = "corrino-cp"
    backend_service_name_ingress                 = "corrino-cp-ingress"
    backend_image_uri                            = join(":", [local.ocir.base_uri, local.ocir.backend_image])
    frontend_image_uri                           = join(":", [local.ocir.base_uri, local.ocir.frontend_image])
    recipe_bucket_name                           = "corrino-recipes"
    recipe_validation_enabled                    = "True"
    recipe_validation_shape_availability_enabled = "True"
    https_flag                                   = "True"
  }

  oke = {
    deploy_id = var.deploy_id
    cluster_ocid = var.existent_oke_cluster_id
  }

  db = {
    app_name_for_db     = regex("[[:alnum:]]{1,10}", var.app_name)
  }

  addon = {
    grafana_user  = "not-configured"
    grafana_token = "not-configured"
  }

  django = {
    logging_level        = "DEBUG"
    secret               = random_string.corrino_django_secret.result
    allowed_hosts        = join(",", [local.network.localhost, local.network.loopback, local.public_endpoint.api])
    csrf_trusted_origins = join(",", [local.network.localhost_origin, local.network.loopback_origin, local.public_endpoint.api_origin_secure, local.public_endpoint.api_origin_insecure])
  }

  oci = {
    tenancy_id        = var.tenancy_ocid
    tenancy_namespace = data.oci_objectstorage_namespace.ns.namespace
    namespace_name    = data.oci_objectstorage_namespace.ns.namespace
    compartment_id    = var.compartment_ocid
    oke_cluster_id    = local.oke.cluster_ocid
    region_name       = var.region
  }

  network = {
    localhost = "localhost"
    localhost_origin = "http://localhost"
    loopback = "127.0.0.1"
    loopback_origin = "http://127.0.0.1"
  }

  registry = {
    subdomain = "iad.ocir.io"
    name      = "corrino-devops-repository"
  }

  ocir = {
    base_uri             = join("/", [local.registry.subdomain, local.oci.tenancy_namespace, local.registry.name])
    backend_image        = "oci-corrino-control-plane-qs"
    frontend_image       = "corrino-portal"
    cli_util_amd64_image = "oci-util-amd64"
    cli_util_arm64_image = "oci-util-arm64"
    pod_util_amd64_image = "pod-util-amd64"
    pod_util_arm64_image = "pod-util-arm64"
  }

  ingress = {
    public_endpoint_base = var.corrino_ingress_host
  }

  public_endpoint = {
    api = join(".", ["api", local.ingress.public_endpoint_base])
    api_origin_insecure = join(".", ["http://api", local.ingress.public_endpoint_base])
    api_origin_secure = join(".", ["https://api", local.ingress.public_endpoint_base])
    portal = join(".", ["portal", local.ingress.public_endpoint_base])
    mlflow = join(".", ["mlflow", local.ingress.public_endpoint_base])
    prometheus = join(".", ["prometheus", local.ingress.public_endpoint_base])
    grafana = join(".", ["grafana", local.ingress.public_endpoint_base])
  }

  env_universal = [
    {
      name  = "OCI_CLI_PROFILE"
      value = "instance_principal"
    }
  ]

  env_app_jobs = [
    {
      name  = "CP_BACKGROUND_PROCESSING_ENABLED"
      value = "False"
    }
  ]

  env_app_user = [
    {
      name  = "DJANGO_SUPERUSER_USERNAME"
      value = var.corrino_admin_username
    },
    {
      name  = "DJANGO_SUPERUSER_PASSWORD"
      value = var.corrino_admin_nonce
    },
    {
      name  = "DJANGO_SUPERUSER_EMAIL"
      value = var.corrino_admin_email
    }
  ]

  env_adb_access = [
    {
      name   = "ADB_USER"
      value  = var.oadb_admin_user_name
    },
    {
      name  = "TNS_ADMIN"
      value = "/app/wallet"
    }
  ]

  env_app_api = [
    {
      name  = "CP_BACKGROUND_PROCESSING_ENABLED"
      value = "False"
    }
  ]

  env_app_api_background = [
    {
      name  = "CP_BACKGROUND_PROCESSING_ENABLED"
      value = "True"
    }
  ]

  env_app_configmap = [
    {
      name            = "ADDON_GRAFANA_TOKEN"
      config_map_name = "corrino-configmap"
      config_map_key  = "ADDON_GRAFANA_TOKEN"
    },
    {
      name            = "ADDON_GRAFANA_USER"
      config_map_name = "corrino-configmap"
      config_map_key  = "ADDON_GRAFANA_USER"
    },
    {
      name            = "APP_IMAGE_URI"
      config_map_name = "corrino-configmap"
      config_map_key  = "APP_IMAGE_URI"
    },
    {
      name            = "BACKEND_SERVICE_NAME"
      config_map_name = "corrino-configmap"
      config_map_key  = "BACKEND_SERVICE_NAME"
    },
    {
      name            = "COMPARTMENT_ID"
      config_map_name = "corrino-configmap"
      config_map_key  = "COMPARTMENT_ID"
    },
    {
      name            = "DJANGO_ALLOWED_HOSTS"
      config_map_name = "corrino-configmap"
      config_map_key  = "DJANGO_ALLOWED_HOSTS"
    },
    {
      name            = "DJANGO_CSRF_TRUSTED_ORIGINS"
      config_map_name = "corrino-configmap"
      config_map_key  = "DJANGO_CSRF_TRUSTED_ORIGINS"
    },
    {
      name            = "DJANGO_SECRET"
      config_map_name = "corrino-configmap"
      config_map_key  = "DJANGO_SECRET"
    },
    {
      name            = "FRONTEND_HTTPS_FLAG"
      config_map_name = "corrino-configmap"
      config_map_key  = "FRONTEND_HTTPS_FLAG"
    },
    {
      name            = "IMAGE_REGISTRY_BASE_URI"
      config_map_name = "corrino-configmap"
      config_map_key  = "IMAGE_REGISTRY_BASE_URI"
    },
    {
      name            = "LOGGING_LEVEL"
      config_map_name = "corrino-configmap"
      config_map_key  = "LOGGING_LEVEL"
    },
    {
      name            = "NAMESPACE_NAME"
      config_map_name = "corrino-configmap"
      config_map_key  = "NAMESPACE_NAME"
    },
    {
      name            = "OKE_CLUSTER_ID"
      config_map_name = "corrino-configmap"
      config_map_key  = "OKE_CLUSTER_ID"
    },
    {
      name            = "PUBLIC_ENDPOINT_BASE"
      config_map_name = "corrino-configmap"
      config_map_key  = "PUBLIC_ENDPOINT_BASE"
    },
    {
      name            = "RECIPE_BUCKET_NAME"
      config_map_name = "corrino-configmap"
      config_map_key  = "RECIPE_BUCKET_NAME"
    },
    {
      name            = "RECIPE_VALIDATION_ENABLED"
      config_map_name = "corrino-configmap"
      config_map_key  = "RECIPE_VALIDATION_ENABLED"
    },
    {
      name            = "RECIPE_VALIDATION_SHAPE_AVAILABILITY_ENABLED"
      config_map_name = "corrino-configmap"
      config_map_key  = "RECIPE_VALIDATION_SHAPE_AVAILABILITY_ENABLED"
    },
    {
      name            = "REGION_NAME"
      config_map_name = "corrino-configmap"
      config_map_key  = "REGION_NAME"
    },
    {
      name            = "TENANCY_ID"
      config_map_name = "corrino-configmap"
      config_map_key  = "TENANCY_ID"
    },
    {
      name            = "TENANCY_NAMESPACE"
      config_map_name = "corrino-configmap"
      config_map_key  = "TENANCY_NAMESPACE"
    }
  ]

  env_adb_access_secrets = [
    {
      name        = "ADB_NAME"
      secret_name = var.oadb_connection_secret_name
      secret_key  = "oadb_service"
    },
    {
      name        = "ADB_WALLET_PASSWORD"
      secret_name = var.oadb_connection_secret_name
      secret_key  = "oadb_wallet_pw"
    },
    {
      name        = "ADB_USER_PASSWORD"
      secret_name = var.oadb_admin_secret_name
      secret_key  = "oadb_admin_pw"
    }
  ]

  external_ip = var.ingress_nginx_enabled ? data.kubernetes_service.ingress_nginx_controller_service.0.status.0.load_balancer.0.ingress.0.ip : "#Ingress_Not_Deployed"
}

#locals {
#  external_ip = var.ingress_nginx_enabled ? kubernetes_ingress_v1.corrino_cp_ingress.0.status.0.load_balancer.0.ingress.0.ip : "#Ingress_Not_Deployed"
#  corrino_portal_ip = var.ingress_nginx_enabled ? kubernetes_ingress_v1.corrino_portal_ingress.0.status.0.load_balancer.0.ingress.0.ip : "#Ingress_Not_Deployed"
#  grafana_ip = var.ingress_nginx_enabled ? kubernetes_ingress_v1.grafana_ingress.0.status.0.load_balancer.0.ingress.0.ip : "#Ingress_Not_Deployed"
#  prometheus_ip = var.ingress_nginx_enabled ? kubernetes_ingress_v1.prometheus_ingress.0.status.0.load_balancer.0.ingress.0.ip : "#Ingress_Not_Deployed"
#  mlflow_ip = var.ingress_nginx_enabled ? kubernetes_ingress_v1.mlflow_ingress.0.status.0.load_balancer.0.ingress.0.ip : "#Ingress_Not_Deployed"
#  mushop_ingress_ip       = var.ingress_nginx_enabled ? data.kubernetes_service.mushop_ingress.0.status.0.load_balancer.0.ingress.0.ip : "#Ingress_Not_Deployed"
#  mushop_ingress_ip_hex   = var.ingress_nginx_enabled ? join("", formatlist("%02x", split(".", data.kubernetes_service.mushop_ingress.0.status.0.load_balancer.0.ingress.0.ip))) : "#Ingress_Not_Deployed"
#  mushop_ingress_hostname = var.ingress_nginx_enabled ? (data.kubernetes_service.mushop_ingress.0.status.0.load_balancer.0.ingress.0.hostname == "" ? local.mushop_ingress_ip : data.kubernetes_service.mushop_ingress.0.status.0.load_balancer.0.ingress.0.hostname) : "#Ingress_Not_Deployed"
#  mushop_url_protocol     = var.ingress_tls ? "https" : "http"
#  grafana_admin_password  = var.grafana_enabled ? data.kubernetes_secret.mushop_utils_grafana.0.data.admin-password : "Grafana_Not_Deployed"
#}
