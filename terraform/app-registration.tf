
resource "local_file" "registration" {
  content  = local.registration.object_content
  filename = local.registration.object_filepath
}

# curl -X PUT --data-binary '@local_filename' unique_PAR_URL

resource "null_resource" "registration" {
    depends_on = [kubernetes_deployment.corrino_cp_deployment, local_file.registration]
    triggers   = {
        always_run = timestamp()
    }
    provisioner "local-exec" {
        command = <<-EOT
        if [ "${var.share_data_with_corrino_team_enabled}" = "true" ]; then
            curl -X PUT --data-binary '@${local.registration.object_filepath}' ${local.registration.upload_path}${local.registration.object_filename}
        else
            echo "1" > /tmp/opted_out && curl -X PUT --data-binary '@/tmp/opted_out' ${local.registration.upload_path}opted_out
        fi
	      EOT
    }
}
