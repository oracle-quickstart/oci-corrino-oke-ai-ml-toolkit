
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

  count = var.mlflow_enabled ? 1 : 0
}

#    REPO_NAME="nvidia"
#    CHART_CANONICAL_NAME="gpu-operator"
#    CHART_URL="https://helm.ngc.nvidia.com/nvidia"
#    NAMESPACE="gpu-operator"
#    RELEASE_NAME="nvidia-dcgm"
#    COMPONENT="nvidia_dcgm_er"

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