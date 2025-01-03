# Corrino OKE Toolkit for AI/ML Workloads

The Corrino OKE Toolkit is a comprehensive collection of Terraform scripts designed to automate the creation and deployment of resources to easily run AI/ML workloads in OCI. It provisions resources such as an OKE cluster, an ATP database instance, and other essential components, which enable you to deploy AI/ML workloads with a simple UI or an API.

The kit includes services such as Grafana and Prometheus for infrastructure monitoring, MLFlow for tracking experiment-level metrics, and KEDA for dynamic auto-scaling based on AI/ML workload metrics rather than infrastructure metrics. This combination provides a scalable, monitored environment optimized for easy deployment and management of AI/ML workloads.

After installing this kit, you can deploy any container image for your AI/ML workloads by simply pointing to the container image, configuring it via the UI / API (container arguments, no. of replicas, shape to deploy the container onto, etc.), and deploying it with the click of a button.

You can deploy the Corrino OKE Toolkit using the button below:

[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/oracle-quickstart/oci-corrino-oke-ai-ml-toolkit/releases/download/zip-file/oci-corrino-oke-ai-ml-toolkit.zip)

## Getting Started Guide with Corrino OKE Toolkit
In this "Getting Started" guide, we will walk you through 3 steps: 
1. Deploying Corrino to your tenancy
2. Deploying and monitoring a Corrino recipe
3. Undeploying a recipe

### Pre-requisites
1. VM.GPU.A10.2 GPUs available in the region 

### Step 1: Deploy Corrino 
1. If you have Admin rights, create a compartment called `corrino`. Otherwise, have a tenancy admin do the following: (1) create a compartment named `corrino` and (2) apply the policies in the Policies section below inside the root compartment of your tenancy.
2. Create an OKE cluster from OCI console in the compartment. **Important:** Select `Managed` for node type; select `Public endpoint` for the Kubernetes API endpoint; select at least `32GB` for "Amount of memory" for the VM.Standard.E3.Flex nodes; do not change other default options.
3. Click on “Deploy to Oracle Cloud” in this page above, which will navigate you to the “Create Stack” page in OCI Console.
4. Follow the on-screen instructions on the Create Stack screen. Additional notes:
    - For "Workspace name" and "Deploy ID" enter short alphanumeric names less than 6 characters each
    - For Corrino Version, enter `latest`
    - Select the OKE cluster that you just created
    - If you are a tenancy admin, select "Create OCI policy and dynamic group for control plane?”. If you are not the tenancy admin and your tenancy admin already applied the policies in the Policies section, do not select “Create OCI policy and dynamic group for control plane?”
    - For Domain Options, select `nip.io` for quick testing. For more advanced use cases, select "custom" and enter your custom domain name - reach out to us if you need help with updating the A records correctly.
5. Select “Run apply” in the “Review” section and click on Create
6. Monitor the deployment status under Resource Manager -> Stacks. After the Job status changes to `Succeeded`, go to the Application Information tab under Stack Details. Click on “Corrino API URL” button to access the Corrino API 

### Step 2: Deploy a vLLM Inference recipe 
1. Click on the `/deployment` endpoint in the API (api.<sub-domain>.corrino-oci.com)
2. Copy and paste this sample inference recipe (https://github.com/vishnukam3/oci-oke-ai-ml-sample-recipes/blob/main/vllm_inference_sample_recipe.json) in the “Content:” text area and click “POST”
3. Check the deployment status using the `/deployment` endpoint. Note down the `deployment ID`. Once the status changes to `monitoring`, you can proceed to the next step
4. Go to the `/deployment_digests/<deployment_id>` endpoint to find the endpoint URL (`digest.data.assigned_service_endpoint`)
5. Test the endpoint on Postman
    ```json
    POST https://<digest.data.assigned_service_endpoint>/v1/completions 
    { 
        "model": "/models/NousResearch/Meta-Llama-3.1-8B-Instruct", 
        "prompt": "Q: What is the capital of the United States?\nA:", 
        "max_tokens": 100, 
        "temperature": 0.7, 
        "top_p": 1.0, 
        "n": 1, 
        "stream": false, 
        "stop": "\n" 
    }
    ```
7. Go to Grafana to monitor the node. Click on the `/workspaces` endpoint and go to the URL under `add_ons.grafana.public_endpoint` in the response JSON. Use `add_ons.grafana.username` and `add_ons.grafana.token` as the username and password to sign into Grafana. 

### Step 3: Undeploy the recipe 
Undeploy the recipe to free up the resources again by going to the `/undeploy` endpoint and sending the following POST request: 
```json
{
    “deployment_uuid”: “<deployment_id>”
}
```

### Additional Resources
Corrino API Documentation: Coming Soon 
Corrino Sample recipes: https://github.com/vishnukam3/oci-oke-ai-ml-sample-recipes 

## Policies 
Allow group 'Default'/'SecondUserGroup' to inspect all-resources in tenancy  

Allow group 'Default'/'SecondUserGroup' to manage instance-family in compartment corrino 

Allow group 'Default'/'SecondUserGroup' to use subnets in compartment corrino 

Allow group 'Default'/'SecondUserGroup' to manage virtual-network-family in compartment corrino 

Allow group 'Default'/'SecondUserGroup' to use vnics in compartment corrino 

Allow group 'Default'/'SecondUserGroup' to use network-security-groups in compartment corrino 

Allow group 'Default'/'SecondUserGroup' to manage public-ips in compartment corrino 

Allow group 'Default'/'SecondUserGroup' to manage cluster-family in compartment corrino 

Allow group 'Default'/'SecondUserGroup' to manage orm-stacks in compartment corrino 

Allow group 'Default'/'SecondUserGroup' to manage orm-jobs in compartment corrino 

Allow group 'Default'/'SecondUserGroup' to manage vcns in compartment corrino 

Allow group 'Default'/'SecondUserGroup' to manage subnets in compartment corrino 

Allow group 'Default'/'SecondUserGroup' to manage internet-gateways in compartment corrino 

Allow group 'Default'/'SecondUserGroup' to manage nat-gateways in compartment corrino 

Allow group 'Default'/'SecondUserGroup' to manage route-tables in compartment corrino 

Allow group 'Default'/'SecondUserGroup' to manage security-lists in compartment corrino 

Allow group 'Default'/'SecondUserGroup' to inspect clusters in compartment corrino 

Allow group 'Default'/'SecondUserGroup' to use cluster-node-pools in compartment corrino 

Allow group 'Default'/'SecondUserGroup' to read cluster-work-requests in compartment corrino 

Allow group 'Default'/'SecondUserGroup' to manage service-gateways in compartment corrino 

Allow group 'Default'/'SecondUserGroup' to use cloud-shell in compartment corrino 

Allow group 'Default'/'SecondUserGroup' to read vaults in compartment corrino 

Allow group 'Default'/'SecondUserGroup' to read keys in compartment corrino 

Allow group 'Default'/'SecondUserGroup' to use compute-capacity-reservations in compartment corrino 

Allow group 'Default'/'SecondUserGroup' to read metrics in compartment corrino 

Allow group 'Default'/'SecondUserGroup' to manage autonomous-database-family in compartment corrino 

## Frequently asked questions 

**What is a secure way for me to test Corrino out in my tenancy?**
Create a seperate compartment, create a new OKE cluster, and then deploy Corrino to the cluster. 

**What containers and resources exactly get deployed to my tenancy when I deploy Corrino?**
Corrino’s deployment Terraform deploys Corrino’s front-end and back-end containers, Grafana, Prometheus for infrastructure monitoring, MLFlow for tracking experiment-level metrics, and KEDA for dynamic auto-scaling based on AI/ML workload metrics rather than infrastructure metrics. 

**How can I run an inference benchmarking script?**
For inference benchmarking, we recommend deploying a vLLM recipe with Corrino and then using LLMPerf to run benchmarking using the endpoint. Reach out to us if you are interested in more details. 

**What is the full list of recipes available?**
Currently, we have an inference recipe, a fine-tuning recipe, and an MLCommons fine-tuning benchmarking recipe with a Llama-2-70B model that are complete. We have several others in the works (e.g. a RAG recipe) that we have built POCs for. If you are interested in additional recipes, please contact us. 

**How can I view the deployment logs to see if something is wrong?**
You can use kubectl to view the pod logs. 

**Can you set up auto-scaling?**
Yes. If you are interested in this, please reach out to us. 

**Which GPUs can I deploy this to?**
Any Nvidia GPUs that are available in your region. 

**What if you already have another cluster?**
You can deploy Corrino to the existing cluster as well. However, we have not yet done extensive testing to confirm if Corrino would be stable on a cluster that already has other workloads running. 

### Cleanup

With the use of Terraform, the [Resource Manager][orm] stack is also responsible for terminating the OKE Starter Kit application.

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
