# Copyright (c) 2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# Verrazzano Operator Helm Chart

resource "helm_release" "v8o_operator" {
  name      = "verrazzano-operator"
  chart     = "${path.module}/charts/verrazzano-operator"
  namespace = var.chart_namespace

  set {
    name  = "issuer.email"
    value = var.ingress_email_issuer
  }

}
