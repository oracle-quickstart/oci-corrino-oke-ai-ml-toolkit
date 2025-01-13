# Copyright (c) 2025, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

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
        curl -X PUT --data-binary '@${local.registration.object_filepath}' ${local.registration.bucket_par}${local.registration.object_filename}
	    EOT
    }
  count = var.share_data_with_corrino_team_enabled ? 1 : 0

}
