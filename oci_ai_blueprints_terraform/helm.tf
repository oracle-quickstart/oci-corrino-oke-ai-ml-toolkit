
#    REPO_NAME="community-charts"
#    CHART_CANONICAL_NAME="mlflow"
#    CHART_URL='https://community-charts.github.io/helm-charts'
#    RELEASE_NAME="mlflow"
#    NAMESPACE="default"
#    COMPONENT="mlflow"


resource "helm_release" "mlflow" {
  name       = "mlflow"
  repository = "https://community-charts.github.io/helm-charts"
  chart      = "mlflow"
  namespace  = "default"
  wait       = false

  count = var.bring_your_own_mlflow ? 0 : 1
}

#    REPO_NAME="nvidia"
#    CHART_CANONICAL_NAME="gpu-operator"
#    CHART_URL="https://helm.ngc.nvidia.com/nvidia"
#    NAMESPACE="gpu-operator"
#    RELEASE_NAME="nvidia-dcgm"
#    COMPONENT="nvidia_dcgm_er"

resource "helm_release" "nvidia-dcgm" {
  name             = "nvidia-dcgm"
  repository       = "https://helm.ngc.nvidia.com/nvidia"
  chart            = "gpu-operator"
  namespace        = "gpu-operator"
  create_namespace = true
  wait             = false

  # Create the release if either DCGM or MIG is enabled.
  count = var.bring_your_own_nvidia_gpu_operator ? 0 : 1

  dynamic "set" {
    for_each = var.bring_your_own_nvidia_gpu_operator ? [] : [1]
    content {
      name  = "mig.strategy"
      value = "mixed"
    }
  }
}

resource "helm_release" "keda" {
  name             = "keda"
  repository       = "https://kedacore.github.io/charts"
  chart            = "keda"
  namespace        = "keda"
  create_namespace = true
  wait             = false

  count = var.bring_your_own_keda ? 0 : 1
}

resource "helm_release" "lws" {
  name             = "lws"
  chart            = "${path.module}/lws" # Use the local path to the chart folder
  namespace        = "lws-system"
  create_namespace = true
  wait             = false
  version          = "0.1.0" // Optional: specify the version if needed

  count = var.bring_your_own_lws ? 0 : 1
}

