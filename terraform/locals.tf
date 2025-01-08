locals {

  ts = timestamp()

  app = {
    backend_service_name                         = "corrino-cp"
    backend_service_name_origin                  = "http://corrino-cp"
    backend_service_name_ingress                 = "corrino-cp-ingress"
#    backend_image_uri_base                       = join(":", [local.ocir.base_uri, local.ocir.backend_image])
    backend_image_uri                            = format("${local.ocir.base_uri}:${local.ocir.backend_image}-${local.versions.corrino_version}")
    frontend_image_uri                           = join(":", [local.ocir.base_uri, local.ocir.frontend_image])
    recipe_bucket_name                           = "corrino-recipes"
    recipe_validation_enabled                    = "True"
    recipe_validation_shape_availability_enabled = "True"
    https_flag                                   = "False"
  }

  registration = {
    object_filename = format("corrino-registration-%s", random_string.registration_id.result)
    object_filepath = format("%s/%s", abspath(path.root), random_string.registration_id.result)
    object_content = join("\n", [
      "-----------------------------------------------",
      "Corrino Registration",
      "-----------------------------------------------",
      format("Registration ID  : %s", random_string.registration_id.result),
      format("Deploy DateTime  : %s", local.ts),
      format("Administrator    : %s", var.corrino_admin_email),
      format("Workspace Name   : %s", var.app_name),
      format("Deploy ID        : %s", var.deploy_id),
      format("Corrino Version  : %s", var.corrino_version),
      format("Tenancy OCID     : %s", local.oci.tenancy_id),
      format("OKE Cluster OCID : %s", local.oke.cluster_ocid),
      format("Region           : %s", local.oci.region_name),
   ]
    )
    bucket_par = "https://objectstorage.us-ashburn-1.oraclecloud.com/p/bqCfQwvzAZPCnxehCZs1Le5V2Pajn3j4JsFzb5CWHRNvtQ4Je-Lk_ApwCcurdpYT/n/iduyx1qnmway/b/corrino-terraform-registry/o/"
  }

  versions = {
    corrino_version   = var.corrino_version
  }

  oke = {
    deploy_id = var.deploy_id
    cluster_ocid = var.existent_oke_cluster_id
  }

  db = {
    app_name_for_db     = regex("[[:alnum:]]{1,10}", var.app_name)
  }

  addon = {
    grafana_user  = "admin"
    grafana_token = module.oke-quickstart.grafana_admin_password
  }

  django = {
    logging_level        = "DEBUG"
    secret               = random_string.corrino_django_secret.result
    allowed_hosts        = join(",", [local.network.localhost, local.network.loopback, local.public_endpoint.api, local.app.backend_service_name])
    csrf_trusted_origins = join(",", [local.network.localhost_origin, local.network.loopback_origin, local.public_endpoint.api_origin_secure, local.public_endpoint.api_origin_insecure, local.app.backend_service_name_origin])
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
    external_ip = var.ingress_nginx_enabled ? data.kubernetes_service.ingress_nginx_controller_service.0.status.0.load_balancer.0.ingress.0.ip : "#Ingress_Not_Deployed"
  }

  registry = {
    subdomain = "iad.ocir.io"
    name      = "corrino-devops-repository"
    source_tenancy_namespace = "iduyx1qnmway"
  }

  ocir = {
    base_uri             = join("/", [local.registry.subdomain, local.registry.source_tenancy_namespace, local.registry.name])
    backend_image        = "oci-corrino-cp"
    frontend_image       = "corrino-portal"
    cli_util_amd64_image = "oci-util-amd64"
    cli_util_arm64_image = "oci-util-arm64"
    pod_util_amd64_image = "pod-util-amd64"
    pod_util_arm64_image = "pod-util-arm64"
  }

  domain = {
    corrino_oci_mode = "corrino-oci.com"
    corrino_oci_fqdn = format("%s.corrino-oci.com", random_string.subdomain.result)

    nip_io_mode = "nip.io"
    nip_io_fqdn = format("%s.nip.io", replace(local.network.external_ip, ".", "-"))

    custom_mode = "custom"
    custom_fqdn = var.fqdn_custom_domain
  }

  fqdn = {
    name = var.fqdn_domain_mode_selector == local.domain.custom_mode ? local.domain.custom_fqdn : ( var.fqdn_domain_mode_selector == local.domain.nip_io_mode ? local.domain.nip_io_fqdn : local.domain.corrino_oci_fqdn )
    is_nip_io_mode = var.fqdn_domain_mode_selector == local.domain.nip_io_mode ? true : false
    is_corrino_com_mode = var.fqdn_domain_mode_selector == local.domain.corrino_oci_mode ? true : false
    is_custom_mode = var.fqdn_domain_mode_selector == local.domain.custom_mode ? true : false
  }

  public_endpoint = {
    api = join(".", ["api", local.fqdn.name])
    api_origin_insecure = join(".", ["http://api", local.fqdn.name])
    api_origin_secure = join(".", ["https://api", local.fqdn.name])
    portal = join(".", ["portal", local.fqdn.name])
    mlflow = join(".", ["mlflow", local.fqdn.name])
    prometheus = join(".", ["prometheus", local.fqdn.name])
    grafana = join(".", ["grafana", local.fqdn.name])
  }

  env_universal = [
    {
      name  = "OCI_CLI_PROFILE"
      value = "instance_principal"
    },
    {
      name  = "TERRAFORM_TIMESTAMP"
      value = local.ts
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
      name            = "CORRINO_VERSION"
      config_map_name = "corrino-configmap"
      config_map_key  = "CORRINO_VERSION"
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

}

#   kubectl get secret --namespace cluster-tools grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
#  grafana_admin_password  = var.grafana_enabled ? data.kubernetes_secret.grafana_password.0.data.admin-password : "Grafana_Not_Deployed"

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

