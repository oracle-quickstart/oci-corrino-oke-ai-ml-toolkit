# Corrino OKE Toolkit for AI/ML Workloads

The Corrino OKE Toolkit is a comprehensive collection of Terraform scripts designed to automate the creation and deployment of resources to easily run AI/ML workloads in OCI. It provisions resources such as an OKE cluster, an ATP database instance, and other essential components, which enable you to deploy AI/ML workloads with a simple UI or an API.

The kit includes services such as Grafana and Prometheus for infrastructure monitoring, MLFlow for tracking experiment-level metrics, and KEDA for dynamic auto-scaling based on AI/ML workload metrics rather than infrastructure metrics. This combination provides a scalable, monitored environment optimized for easy deployment and management of AI/ML workloads.

After installing this kit, you can deploy any container image for your AI/ML workloads by simply pointing to the container image, configuring it via the UI / API (container arguments, no. of replicas, shape to deploy the container onto, etc.), and deploying it with the click of a button.

## Getting Started
You can deploy the Corrino OKE Toolkit using the button below:

[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/oracle-quickstart/oci-oke-starter-kit/blob/main/corrino-quick-start-vF.zip)

### Cleanup

With the use of Terraform, the [Resource Manager][orm] stack is also responsible for terminating the Corrino OKE Toolkit application.

Follow these steps to completely remove all provisioned resources:

1. Return to the Oracle Cloud Infrastructure [Console](https://cloud.oracle.com/resourcemanager/stacks)

  > `Home > Developer Services > Resource Manager > Stacks`

2. Select the stack created previously to open the Stack Details view
3. From the Stack Details, select `Terraform Actions > Destroy`
4. Confirm the **Destroy** job when prompted

  > The job status will be **In Progress** while resources are terminated

5. Once the destroy job has succeeded, return to the Stack Details page
6. Click `Delete Stack` and confirm when prompted

---

## Questions

If you have an issue or a question, please contact Vishnu Kammari at vishnu.kammari@oracle.com.
