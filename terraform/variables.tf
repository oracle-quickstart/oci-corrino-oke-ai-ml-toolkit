# Copyright (c) 2023 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

# -----------------------------------
# OCI
# -----------------------------------

variable "existent_oke_cluster_id" {}

variable "existent_vcn_ocid" {}

variable "existent_vcn_compartment_ocid" {}

variable "existent_oke_k8s_endpoint_subnet_ocid" {}

variable "existent_oke_nodes_subnet_ocid" {}

variable "existent_oke_load_balancer_subnet_ocid" {}

# -----------------------------------
# OCI
# -----------------------------------

variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}
variable "user_ocid" {
  default = ""
}
variable "fingerprint" {
  default = ""
}
variable "private_key_path" {
  default = ""
}
variable "home_region" {
  default = ""
}

# -----------------------------------
# Corrino App
# -----------------------------------

variable "app_name" {
  type = string
}

variable "deploy_id" {
  type = string
}

variable "policy_creation_enabled" {
  description = "Create policies to enable apps to view and manage compute resources. If selected and user does not have permissions to create policies in root tenancy, build will fail."
  type = bool
  default = false
}

# -----------------------------------
# Corrino User
# -----------------------------------

variable "corrino_admin_username" {
    description = "The user name used to login to Corrino"
    type = string
}

variable "corrino_admin_nonce" {
    description = "The password used to login to Corrino"
    type = string
}

variable "corrino_admin_email" {
    description = "The email address used to identify the Corrino user"
    type = string
}

# -----------------------------------
# Corrino FQDN
# -----------------------------------

variable "corrino_ingress_host" {
    description = "FQDN (Fully Qualified Domain Name) can be a simple domain (example.com) or have an A-Record for a subdomain (*.foo.example.com).  You will need to create a domain registrar A-Record using the load balancer public IP that is provisioned."
    type = string
}

# -----------------------------------
# Helm
# -----------------------------------

variable "metrics_server_enabled" {
  type = bool
  default = true
}
variable "ingress_nginx_enabled" {
  type = bool
  default = true
}
variable "cert_manager_enabled" {
  type = bool
  default = true
}
variable "prometheus_enabled" {
  type = bool
  default = true
}
variable "grafana_enabled" {
  type = bool
  default = true
}
variable "mlflow_enabled" {
  type = bool
  default = true
}
variable "nvidia_dcgm_enabled" {
  type = bool
  default = true
}
variable "keda_enabled" {
  type = bool
  default = true
}

# -----------------------------------
# Autonomous Database
# -----------------------------------

variable "oadb_admin_user_name" {
  default = "admin"
}
variable "oadb_admin_secret_name" {
  default = "oadb-admin"
}
variable "oadb_connection_secret_name" {
  default = "oadb-connection"
}
variable "oadb_wallet_secret_name" {
  default = "oadb-wallet"
}

variable "autonomous_database_cpu_core_count" {
  default = 1
}

variable "autonomous_database_data_storage_size_in_tbs" {
  default = 1
}

variable "autonomous_database_data_safe_status" {
  default = "NOT_REGISTERED" # REGISTERED || NOT_REGISTERED

  validation {
    condition     = var.autonomous_database_data_safe_status == "REGISTERED" || var.autonomous_database_data_safe_status == "NOT_REGISTERED"
    error_message = "Sorry, but database license model can only be REGISTERED or NOT_REGISTERED."
  }
}

variable "autonomous_database_db_version" {
  default = "19c"
}

variable "autonomous_database_license_model" {
  default = "BRING_YOUR_OWN_LICENSE" # LICENSE_INCLUDED || BRING_YOUR_OWN_LICENSE

  validation {
    condition     = var.autonomous_database_license_model == "BRING_YOUR_OWN_LICENSE" || var.autonomous_database_license_model == "LICENSE_INCLUDED"
    error_message = "Sorry, but database license model can only be BRING_YOUR_OWN_LICENSE or LICENSE_INCLUDED."
  }
}

variable "autonomous_database_is_auto_scaling_enabled" {
  default = false
}

variable "autonomous_database_is_free_tier" {
  default = false
}
variable "autonomous_database_visibility" {
  default = "Public"

  validation {
    condition     = var.autonomous_database_visibility == "Private" || var.autonomous_database_visibility == "Public"
    error_message = "Database visibility must be be Private or Public."
  }
}
variable "autonomous_database_wallet_generate_type" {
  default = "SINGLE"
}

