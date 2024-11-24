

output "cluster_tools_namespace" {
#  value = var.cluster_tools_namespace
   value = kubernetes_namespace.cluster_tools
}

output "helm_release_ingress_nginx" {
   value = helm_release.ingress_nginx
}

