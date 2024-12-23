# Configuration authentication-less
#provider "smtp" {
#  authentication  = false
#  host            = "smtp.example.com"
#  port            = "25"
#}
#
#resource "smtp_send_mail" "send_to_team" {
#  to      = local.notification_recipients
#  from    = "corrino@oracle.com"
#  subject = "Corrino Workspace Terraform Report"
#  body    = format("workspace / %s / %s / %s", local.fqdn.name, local.network.external_ip, timestamp())
#  depends_on = [kubernetes_deployment.corrino_cp_deployment]
#}
