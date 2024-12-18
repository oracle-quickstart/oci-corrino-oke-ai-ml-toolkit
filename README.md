# OKE Starter Kit for AI/ML Workloads

The OKE Starter Kit is a comprehensive collection of Terraform scripts designed to automate the creation and deployment of resources to easily run AI/ML workloads in OCI. It provisions resources such as an OKE cluster, an ATP database instance, and other essential components, which enable you to deploy AI/ML workloads with a simple UI or an API.

The kit includes services such as Grafana and Prometheus for infrastructure monitoring, MLFlow for tracking experiment-level metrics, and KEDA for dynamic auto-scaling based on AI/ML workload metrics rather than infrastructure metrics. This combination provides a scalable, monitored environment optimized for easy deployment and management of AI/ML workloads.

After installing this kit, you can deploy any container image for your AI/ML workloads by simply pointing to the container image, configuring it via the UI / API (container arguments, no. of replicas, shape to deploy the container onto, etc.), and deploying it with the click of a button.

You can deploy the OKE Starter Kit using the button below:

[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/oracle-quickstart/oci-oke-starter-kit/blob/main/corrino-quick-start-vF.zip)

## Getting Started with OKE Starter Kit

This is a Terraform configuration that deploys the OKE Starter Kit on [Oracle Cloud Infrastructure][oci].

The repository contains the application code as well as the [Terraform][tf] code to create a [Resource Manager][orm] stack, that creates all the required resources and configures the application on the created resources. To simplify getting started, the Resource Manager Stack is created as part of each [release](https://github.com/oracle-quickstart/oci-cloudnative/releases)

The steps below guide you through deploying the application on your tenancy using the OCI Resource Manager.

1. Download the latest [`oke-starter-kit-stack-latest.zip`](../../releases/latest/download/mushop-basic-stack-latest.zip) file.
2. [Login](https://cloud.oracle.com/resourcemanager/stacks/create) to Oracle Cloud Infrastructure to import the stack
    > `Home > Developer Services > Resource Manager > Stacks > Create Stack`
3. Upload the `oke-starter-kit-stack-latest.zip` file that was downloaded earlier, and provide a name and description for the stack
4. Configure the stack
   1. **Database Name** - You can choose to provide a database name (optional)
   2. **Node Count** - Select if you want to deploy one or two application instances.
   3. **SSH Public Key** - (Optional) Provide a public SSH key if you wish to establish SSH access to the compute node(s).
5. Review the information and click Create button.
   > The upload can take a few seconds, after which you will be taken to the newly created stack
6. On Stack details page, click on `Terraform Actions > Apply`

All the resources will be created, and the URL to the load balancer will be displayed as `lb_public_url` as in the example below.
> The same information is displayed on the Application Information tab

```text
Outputs:

autonomous_database_password = <generated>

comments = The application URL will be unavailable for a few minutes after provisioning, while the application is configured

dev = Made with ❤ by Oracle Developers

lb_public_url = http://xxx.xxx.xxx.xxx
```

> The application is being deployed to the compute instances asynchronously, and it may take a couple of minutes for the URL to serve the application.

### Cleanup

With the use of Terraform, the [Resource Manager][orm] stack is also responsible for terminating the OKE Starter Kit application.

Follow these steps to completely remove all provisioned resources:

1. Return to the Oracle Cloud Infrastructure [Console](https://cloud.oracle.com/resourcemanager/stacks)

  > `Home > Developer Services > Resource Manager > Stacks`

1. Select the stack created previously to open the Stack Details view
1. From the Stack Details, select `Terraform Actions > Destroy`
1. Confirm the **Destroy** job when prompted

  > The job status will be **In Progress** while resources are terminated

1. Once the destroy job has succeeded, return to the Stack Details page
1. Click `Delete Stack` and confirm when prompted

---

## Questions

If you have an issue or a question, please contact Vishnu Kammari at vishnu.kammari@oracle.com.


## Create Prerequisites

---

### Administrative Role

You will need roles to:

* Create a compartment
* Create a dynamic group within an Identity Domain
* Create a policy at the root Compartment level
* Create an OKE Cluster
* Create a VCN
* Create a LoadBalancer
* Create an Object Storage Bucket

### Compartment

* Create a compartment
  * Capture the OCID for the compartment
  * Assuming your compartment is named `corrino-compartment`

  
### Dynamic Group

* Create a dynamic group
  * Assuming you are creating dynamic group in the `Default` Identity Domain:
  * Assuming your dynamic group name is `corrino-dg`:


    ALL {instance.compartment.id = 'ocid1.compartment.oc1..'}	
    ALL {resource.compartment.id = 'ocid1.compartment.oc1..'}

### Policy

* Create a new policy in the root compartment.
  * Assuming you are creating dynamic group in the `Default` Identity Domain:
  * Assuming your dynamic group name is `corrino-dg`


    Allow dynamic-group 'Default'/'corrino-dg' to use all-resources in tenancy	
    Allow dynamic-group 'Default'/'corrino-dg' to manage all-resources in compartment corrino-compartment

If your compartment is nested beneath other compartments (ie not at the top level) as in:

* root
  * compA
    * compB
      * compC
        * corrino-compartment


    Allow dynamic-group 'Default'/'corrino-dg' to manage all-resources in compartment compA:compB:compC:corrino-compartment

### OKE Cluster

* Create an OKE cluster using the OCI Console
* Using the wizard is fine.

Write Down:

* The OKE Cluster OCID
* The VCN OCID
* Each Subnet OCID (there will be 3)

---

## Create a Resource Manager Stack

* Use the `Deploy to Oracle Cloud` link.
* Provide the inputs for OCIDS
  * Compartment OCID
  * OKE Cluster OCID
  * VCN OCID
    * Node Subnet
    * LB Subnet
    * Endpoint Subnet


