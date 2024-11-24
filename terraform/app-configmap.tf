resource "kubernetes_config_map" "corrino-configmap" {
  metadata {
    name = "corrino-configmap"
  }

  data = {
    APP_IMAGE_URI                                = local.app.backend_image_uri
    ADDON_GRAFANA_TOKEN                          = local.addon.grafana_token
    ADDON_GRAFANA_USER                           = local.addon.grafana_user
    BACKEND_SERVICE_NAME                         = local.app.backend_service_name
    COMPARTMENT_ID                               = local.oci.compartment_id
    DJANGO_ALLOWED_HOSTS                         = local.django.allowed_hosts
    DJANGO_CSRF_TRUSTED_ORIGINS                  = local.django.csrf_trusted_origins
    DJANGO_SECRET                                = local.django.secret
    FRONTEND_HTTPS_FLAG                          = local.app.https_flag
    IMAGE_REGISTRY_BASE_URI                      = local.ocir.base_uri
    LOGGING_LEVEL                                = local.django.logging_level
    NAMESPACE_NAME                               = local.oci.namespace_name
    OKE_CLUSTER_ID                               = local.oci.oke_cluster_id
    PUBLIC_ENDPOINT_BASE                         = local.ingress.public_endpoint_base
    RECIPE_BUCKET_NAME                           = local.app.recipe_bucket_name
    RECIPE_VALIDATION_ENABLED                    = local.app.recipe_validation_enabled
    RECIPE_VALIDATION_SHAPE_AVAILABILITY_ENABLED = local.app.recipe_validation_shape_availability_enabled
    REGION_NAME                                  = local.oci.region_name
    TENANCY_ID                                   = local.oci.tenancy_id
    TENANCY_NAMESPACE                            = local.oci.tenancy_namespace
    EXISTENT_OKE_CLUSTER_MODE = "True"
  }
}