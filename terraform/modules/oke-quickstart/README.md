# Terraform Oracle Container Engine for Kubernetes ([OKE][oke]) Quickstart Module

---
> __Warning__

$${\color{red}This \space is \space a \space pre-release \space version \space of \space the \space module, \space some \space features}$$
$${\color{red}have \space not \space been \space migrated \space from \space MuShop's}$$
$${\color{red}OKE \space Cluster \space deployment \space yet.}$$
---

[![Stack Release](https://img.shields.io/github/v/release/oracle-quickstart/terraform-oci-oke-quickstart.svg)](https://github.com/oracle-quickstart/terraform-oci-oke-quickstart/releases)
[![Stack Build](https://img.shields.io/github/actions/workflow/status/oracle-quickstart/terraform-oci-oke-quickstart/stack.yml?branch=main&label=stack&logo=oracle&logoColor=red)][magic_oke_stack]
![AquaSec TFSec](https://img.shields.io/github/actions/workflow/status/oracle-quickstart/terraform-oci-oke-quickstart/tfsec.yml?branch=main&label=tfsec&logo=aqua)
![Terraform](https://img.shields.io/badge/terraform->%3D%201.1-%235835CC.svg?logo=terraform)
![Stack License](https://img.shields.io/github/license/oracle-quickstart/terraform-oci-oke-quickstart)
![Stack Downloads](https://img.shields.io/github/downloads/oracle-quickstart/terraform-oci-oke-quickstart/total?logo=terraform)
[![GitHub issues](https://img.shields.io/github/issues/oracle-quickstart/terraform-oci-oke-quickstart.svg)](https://github.com/oracle-quickstart/terraform-oci-oke-quickstart/issues)

This module handles opinionated Oracle Container Engine for [Kubernetes][kubernetes_101] ([OKE][oke]) cluster creation on Oracle Cloud Infrastructure ([OCI][oci]). This module is designed to be used with the [OCI Resource Manager][oci_rm] to deploy a cluster in a single step. The module can also be used with the [OCI Terraform Provider][oci_tf_provider] to deploy a cluster using local or CloudShell Terraform cli.

>__Note__: This project is an alternative to easily create an OKE cluster without the need to use external workarounds and do not need to create compute bastions or jump servers, even if deploying using private endpoints. This is a __NO__(`null_resource` ,`remote_exec`, `operator instance`, `bastion_or_jump_server`, `out_of_tf_state_sh_scripts`) project

Sub modules are provided to create a cluster with a single node pool, or a cluster with multiple node pools. Enables Cluster Autoscaler, OCI Vault(KMS) for customer-managed encryption keys for secrets, block volumes. The module also provides a sub module to create a cluster with a single node pool and a private endpoint to Oracle Resource Manager (ORM).

This repo also includes the modules for deploying the following cluster components on the OKE cluster:

| Component | Description |
| --- | --- |
| [Kubernetes Cluster Autoscaler](modules/cluster-tools/oke-cluster-autoscaler.tf) | This module deploys the Kubernetes Cluster Autoscaler on the OKE cluster. |
| [Metrics Server](modules/cluster-tools/metrics-server.tf) | This module deploys the Metrics Server on the OKE cluster. |
| [Kubernetes Ingress Nginx Controller](modules/cluster-tools/ingress-nginx.tf) | This module deploys the Nginx Ingress Controller on the OKE cluster. |
| [Prometheus](modules/cluster-tools/prometheus.tf) | This module deploys the Prometheus monitoring system on the OKE cluster. |
| [Grafana](modules/cluster-tools/grafana.tf) | This module deploys the Grafana monitoring system on the OKE cluster. |
| [Cert Manager](modules/cluster-tools/cert-manager.tf) | This module deploys the Cert Manager on the OKE cluster. |
<!-- | [Fluentd](modules/fluentd) | This module deploys a Fluentd agent on the OKE cluster. |
| [Kubernetes Dashboard](modules/kubernetes-dashboard) | This module deploys the Kubernetes Dashboard on the OKE cluster. |
| [Jaeger](modules/jaeger) | This module deploys the Jaeger tracing system on the OKE cluster. |
| [Kiali](modules/kiali) | This module deploys the Kiali tracing system on the OKE cluster. |
| [Keycloak](modules/keycloak) | This module deploys the Keycloak identity and access management system on the OKE cluster. | -->

## Usage

There are multiple examples included in the [examples](https://github.com/oracle-quickstart/terraform-oci-oke-quickstart/tree/main/examples) folder but simple usage is as follows:

```hcl
module "oke-quickstart" {
  source = "github.com/oracle-quickstart/terraform-oci-oke-quickstart?ref=0.8.0"

  # Oracle Cloud Infrastructure Tenancy and Compartment OCID
  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  region           = var.region

  # Note: Just few arguments are showing here to simplify the basic example. All other arguments are using default values.
  # App Name to identify deployment. Used for naming resources.
  app_name = "Basic"

  # Freeform Tags + Defined Tags. Tags are applied to all resources.
  tag_values = { "freeformTags" = { "Environment" = "Development", "DeploymentType" = "basic" }, "definedTags" = {} }

  # OKE Cluster arguments
  #   cluster_cni_type = "FLANNEL_OVERLAY" # Use "OCI_VCN_IP_NATIVE" for VCN Native PODs Network

  # OKE Node Pool 1 arguments
  #   node_pool_cni_type_1           = "FLANNEL_OVERLAY" # Use "OCI_VCN_IP_NATIVE" for VCN Native PODs Network
  node_pool_autoscaler_enabled_1     = true
  node_pool_initial_num_worker_nodes_1             = 3                                                                         # Minimum number of nodes in the node pool
  node_pool_max_num_worker_nodes_1 = 10                                                                      # Maximum number of nodes in the node pool
  node_pool_instance_shape_1     = { "instanceShape" = "VM.Standard.E4.Flex", "ocpus" = 2, "memory" = 64 } # If not using a Flex shape, ocpus and memory are ignored

  # VCN for OKE arguments
  vcn_cidr_blocks = "10.20.0.0/16"
}
```

## Deploy Using Oracle Resource Manager

> ___NOTE:___ If you aren't already signed in, when prompted, enter the tenancy and user credentials. Review and accept the terms and conditions.

1. Click to deploy the stack

    [![Deploy to Oracle Cloud][magic_button]][magic_oke_stack]

1. Select the region and compartment where you want to deploy the stack.

1. Follow the on-screen prompts and instructions to create the stack.

1. After creating the stack, click Terraform Actions, and select Plan.

1. Wait for the job to be completed, and review the plan.

1. To make any changes, return to the Stack Details page, click Edit Stack, and make the required changes. Then, run the Plan action again.

1. If no further changes are necessary, return to the Stack Details page, click Terraform Actions, and select Apply.

## Deploy Using the Terraform CLI

### Prerequisites

Create a terraform.tfvars file and populate with the required variables or override existing variables.

Note: An example [tfvars file](examples/terraform.tfvars.example) is included for reference. Using this file is the
preferred way to run the stack from the CLI, because of the large number of variables to manage.

To use this file just copy the example [tfvars file](examples/terraform.tfvars.example) and save it in the outermost directory.
Next, rename the file to __terraform.tfvars__. You can override the example values set in this file.

### Clone the Module

Clone the source code from suing the following command:

```bash
git clone github.com/oracle-quickstart/terraform-oci-oke-quickstart
```

```bash
cd terraform-oci-oke-quickstart
```

### Running Terraform

After specifying the required variables you can run the stack using the following commands:

```bash
terraform init
```

```bash
terraform plan
```

```bash
terraform apply
```

```bash
terraform destroy -refresh=false
```

## Terraform Variables

A complete listing of the Terraform variables used in this stack are referenced [here](VARIABLES.md).
<!-- This document is automatically generated
using the [terraform-docs](https://github.com/terraform-docs/terraform-docs) with the following command:

```bash
terraform-docs markdown table --sort-by required --show inputs --show outputs . > VARIABLES.md
``` -->

## What's a Terraform Module?

A Terraform Module refers to a self-contained packages of Terraform configurations that are managed as a group. This repo
is a Terraform Module and contains many "submodules" which can be composed together to create useful infrastructure patterns.

## Which projects use this Module?

|   |   |   |
|---|---|---|
|![MuShop Logo](./docs/images/mushop-logo.png#gh-light-mode-only)![MuShop Logo - Dark Mode](./docs/images/mushop-logo-inverse.png#gh-dark-mode-only)|[oci-cloudnative (MuShop)](https://github.com/oracle-quickstart/oci-cloudnative)| This project is a reference implementation of a cloud native microservices application on Oracle Cloud Infrastructure (OCI). It is a polyglot multi-tiered application that demonstrates how to build and deploy a cloud native application on OCI using Kubernetes, Docker, Istio and other open source technologies. |
||[oci-micronaut (MuShop)](https://github.com/oracle-quickstart/oci-micronaut)| This project is a fork of the original MuShop implementation which used different technologies for each individual Microservice applicationµ and is designed as a demonstration of how to use Micronaut to build applications for Oracle Cloud. |
|![Unreal Logo](./docs/images/UE_Logo_horizontal_unreal-engine_black.svg#gh-light-mode-only)![Unreal Logo - Dark Mode](./docs/images/UE_Logo_horizontal_unreal-engine_white.svg#gh-dark-mode-only)|[oke-unreal-pixel-streaming](https://github.com/oracle-quickstart/oke-unreal-pixel-streaming)| This project deploys a Kubernetes cluster on Oracle Cloud Infrastructure (OCI) and deploys the Unreal Pixel Streaming demo application on the cluster. |
|![Sysdig Logo](./docs/images/sysdig-logo.svg#gh-light-mode-only)![Sysdig Logo - Dark Mode](./docs/images/sysdig-logo-white-text.svg#gh-dark-mode-only)|[oke-sysdig](https://github.com/oracle-quickstart/oke-sysdig)|This project deploy a Sysdig Secure agent on an OKE cluster.|
|![Snyk Logo](./docs/images/snyk-logo-black.svg#gh-light-mode-only)![Snyk Logo - Dark Mode](./docs/images/snyk-logo-white.svg#gh-dark-mode-only) |[oke-snyk](https://github.com/oracle-quickstart/oke-snyk)|This project deploy a Snyk agent on an OKE cluster.|
> Several other projects, samples, demos, and customers quickstarts also uses this module or used as base.

## How is this Terraform Module versioned?

This Terraform Module follows the principles of [Semantic Versioning](http://semver.org/). You can find each new release,
along with the changelog, in the [Releases Page](https://github.com/hashicorp/terraform-google-consul/releases).

During initial development, the major version will be 0 (e.g., `0.x.y`), which indicates the code does not yet have a
stable API. Once we hit `1.0.0`, we will make every effort to maintain a backwards compatible API and use the MAJOR,
MINOR, and PATCH versions on each release to indicate any incompatibilities.

## Questions

If you have an issue or a question, please take a look at our [FAQs](./FAQs.md) or [open an issue](https://github.com/oracle-quickstart/terraform-oci-oke-quickstart/issues/new).

## Contributing

This project welcomes contributions from the community. Before submitting a pull
request, see [CONTRIBUTING](./CONTRIBUTING.md) for details.

## License

Copyright (c) 2021, 2022 Oracle and/or its affiliates.
Released under the Universal Permissive License (UPL), Version 1.0.
See [LICENSE](./LICENSE) for more details.

[oci]: https://cloud.oracle.com/en_US/cloud-infrastructure
[oci_rm]: https://docs.cloud.oracle.com/iaas/Content/ResourceManager/Concepts/resourcemanager.htm
[oke]: https://www.oracle.com/cloud/cloud-native/container-engine-kubernetes/
[kubernetes_101]: https://www.oracle.com/cloud/cloud-native/container-engine-kubernetes/what-is-kubernetes/
[tf]: https://www.terraform.io
[orm_landing]:https://www.oracle.com/cloud/systems-management/resource-manager/
[oci_tf_provider]: https://www.terraform.io/docs/providers/oci/index.html
[magic_button]: https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg
[magic_oke_stack]: https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/oracle-quickstart/terraform-oci-oke-quickstart/releases/latest/download/terraform-oci-oke-quickstart-stack.zip
