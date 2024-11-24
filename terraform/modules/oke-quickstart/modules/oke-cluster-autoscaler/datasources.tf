# Copyright (c) 2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# Gets supported Kubernetes versions for node pools
data "oci_containerengine_node_pool_option" "node_pool" {
  node_pool_option_id = "all"
}
