# Copyright (c) 2020, 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#


##**************************************************************************
##                          Object Storage
##**************************************************************************
#resource "oci_objectstorage_bucket" "mushop_catalogue_bucket" {
#  compartment_id = local.oke_compartment_ocid
#  namespace      = data.oci_objectstorage_namespace.ns.namespace
#  name           = "mushop-catalogue-bucket-${random_string.deploy_id.result}"
#  access_type    = "ObjectReadWithoutList"
#
#  count = var.mushop_mock_mode_all ? 0 : 1
#}
#
#resource "oci_objectstorage_preauthrequest" "mushop_catalogue_bucket_par" {
#  namespace    = data.oci_objectstorage_namespace.ns.namespace
#  bucket       = oci_objectstorage_bucket.mushop_catalogue_bucket[0].name
#  name         = "mushop-catalogue-bucket-par-${random_string.deploy_id.result}"
#  access_type  = "AnyObjectWrite"
#  time_expires = timeadd(timestamp(), "60m")
#
#  count = var.mushop_mock_mode_all ? 0 : 1
#}
#
#resource "kubernetes_secret" "oos_bucket" {
#  metadata {
#    name      = var.oos_bucket_name
#    namespace = kubernetes_namespace.mushop_namespace.id
#  }
#  data = {
#    region    = var.region
#    name      = "mushop-catalogue-bucket-${random_string.deploy_id.result}"
#    namespace = data.oci_objectstorage_namespace.ns.namespace
#    parUrl    = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.mushop_catalogue_bucket_par[0].access_uri}"
#  }
#  type = "Opaque"
#
#  count = var.mushop_mock_mode_all ? 0 : 1
#}

##**************************************************************************
##                        OCI Service User
##**************************************************************************

#### OCI Service User
#resource "oci_identity_user" "oci_service_user" {
#  compartment_id = var.tenancy_ocid
#  description    = "${var.app_name} Service User for deployment ${random_string.deploy_id.result}"
#  name           = "${local.app_name_normalized}-service-user-${random_string.deploy_id.result}"
#
#  provider = oci.home_region
#
#  count = var.create_oci_service_user ? 1 : 0
#}
#resource "oci_identity_group" "oci_service_user" {
#  compartment_id = var.tenancy_ocid
#  description    = "${var.app_name} Service User Group for deployment ${random_string.deploy_id.result}"
#  name           = "${local.app_name_normalized}-service-user-group-${random_string.deploy_id.result}"
#
#  provider = oci.home_region
#
#  count = var.create_oci_service_user ? 1 : 0
#}
#resource "oci_identity_user_group_membership" "oci_service_user" {
#  group_id = oci_identity_group.oci_service_user[0].id
#  user_id  = oci_identity_user.oci_service_user[0].id
#
#  provider = oci.home_region
#
#  count = var.create_oci_service_user ? 1 : 0
#}
#resource "oci_identity_user_capabilities_management" "oci_service_user" {
#  user_id = oci_identity_user.oci_service_user[0].id
#
#  can_use_api_keys             = "false"
#  can_use_auth_tokens          = "false"
#  can_use_console_password     = "false"
#  can_use_customer_secret_keys = "false"
#  can_use_smtp_credentials     = var.newsletter_subscription_enabled ? "true" : "false"
#
#  provider = oci.home_region
#
#  count = var.create_oci_service_user ? 1 : 0
#}
#resource "oci_identity_smtp_credential" "oci_service_user" {
#  description = "${local.app_name_normalized}-service-user-smtp-credential-${random_string.deploy_id.result}"
#  user_id     = oci_identity_user.oci_service_user[0].id
#
#  provider = oci.home_region
#
#  count = var.create_oci_service_user ? (oci_identity_user_capabilities_management.oci_service_user.0.can_use_smtp_credentials ? 1 : 0) : 0
#}

##**************************************************************************
##                        OCI Email Delivery
##**************************************************************************

#### Email Sender
#resource "oci_email_sender" "newsletter_email_sender" {
#  compartment_id = local.oke_compartment_ocid
#  email_address  = local.newsletter_email_sender
#
#  count = var.create_new_oke_cluster ? (var.newsletter_subscription_enabled ? 1 : 0) : 0
#}

##**************************************************************************
##                      Oracle Cloud Functions
##**************************************************************************

#resource "oci_functions_application" "app_function" {
#  compartment_id = local.oke_compartment_ocid
#  display_name   = "${var.app_name} Application (${random_string.deploy_id.result})"
#  subnet_ids     = [oci_core_subnet.apigw_fn_subnet.0.id, ]
#
#  config     = {}
#  syslog_url = ""
#  trace_config {
#    domain_id  = ""
#    is_enabled = "false"
#  }
#
#  count = var.create_new_oke_cluster ? (var.newsletter_subscription_enabled ? 1 : 0) : 0
#}
#
#resource "oci_functions_function" "newsletter_subscription" {
#  application_id = oci_functions_application.app_function.0.id
#  display_name   = local.newsletter_function_display_name
#  image          = "${var.newsletter_subscription_function_image}:${var.newsletter_subscription_function_image_version}"
#  memory_in_mbs  = local.newsletter_function_memory_in_mbs
#  config = {
#    "APPROVED_SENDER_EMAIL" : local.newsletter_email_sender,
#    "SMTP_HOST" : local.newsletter_function_smtp_host,
#    "SMTP_PORT" : local.newsletter_function_smtp_port,
#    "SMTP_USER" : oci_identity_smtp_credential.oci_service_user.0.username,
#    "SMTP_PASSWORD" : oci_identity_smtp_credential.oci_service_user.0.password,
#  }
#
#  timeout_in_seconds = local.newsletter_function_timeout_in_seconds
#  trace_config {
#    is_enabled = "false"
#  }
#
#  count = var.create_new_oke_cluster ? (var.newsletter_subscription_enabled ? 1 : 0) : 0
#}
#locals {
#  newsletter_function_display_name       = "newsletter-subscription"
#  newsletter_email_sender                = replace(var.newsletter_email_sender, "@", "+${random_string.deploy_id.result}@")
#  newsletter_function_memory_in_mbs      = "128"
#  newsletter_function_timeout_in_seconds = "60"
#  newsletter_function_smtp_host          = "smtp.email.${var.region}.oci.oraclecloud.com"
#  newsletter_function_smtp_port          = "587"
#}

##**************************************************************************
##                          OCI API Gateway
##**************************************************************************
#
#resource "oci_apigateway_gateway" "app_gateway" {
#  compartment_id = local.oke_compartment_ocid
#  endpoint_type  = "PUBLIC"
#  subnet_id      = oci_core_subnet.apigw_fn_subnet.0.id
#  display_name   = "${var.app_name} API Gateway (${random_string.deploy_id.result})"
#
#  response_cache_details {
#    type = "NONE"
#  }
#
#  count = var.create_new_oke_cluster ? (var.newsletter_subscription_enabled ? 1 : 0) : 0
#}
#
#resource "oci_apigateway_deployment" "newsletter_subscription" {
#  compartment_id = local.oke_compartment_ocid
#  gateway_id     = oci_apigateway_gateway.app_gateway.0.id
#  path_prefix    = "/newsletter"
#
#  display_name = local.newsletter_function_display_name
#
#  specification {
#    logging_policies {
#      execution_log {
#        is_enabled = "true"
#        log_level  = "ERROR"
#      }
#    }
#
#    routes {
#      backend {
#        function_id = oci_functions_function.newsletter_subscription.0.id
#        type        = "ORACLE_FUNCTIONS_BACKEND"
#      }
#      logging_policies {
#
#      }
#      methods = ["POST", ]
#      path    = "/subscribe"
#    }
#  }
#
#  count = var.create_new_oke_cluster ? (var.newsletter_subscription_enabled ? 1 : 0) : 0
#}
