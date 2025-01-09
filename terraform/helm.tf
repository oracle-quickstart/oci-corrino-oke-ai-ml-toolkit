# Copyright (c) 2025, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

resource "helm_release" "mlflow" {
  name       = "mlflow"
  repository = "https://community-charts.github.io/helm-charts"
  chart      = "mlflow"
  namespace  = "default"
  wait       = false

  count = var.mlflow_enabled ? 1 : 0
}

resource "helm_release" "nvidia-dcgm" {
  name       = "nvidia-dcgm"
  repository = "https://helm.ngc.nvidia.com/nvidia"
  chart      = "gpu-operator"
  namespace  = "gpu-operator"
  create_namespace = true
  wait       = false

  count = var.nvidia_dcgm_enabled ? 1 : 0
}

resource "helm_release" "keda" {
  name       = "keda"
  repository = "https://kedacore.github.io/charts"
  chart      = "keda"
  namespace  = "keda"
  create_namespace = true
  wait       = false

  count = var.keda_enabled ? 1 : 0
}