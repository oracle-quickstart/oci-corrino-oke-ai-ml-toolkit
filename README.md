# Corrino OKE Toolkit for AI/ML Workloads

## About Corrino

### Problem

We identified 3 areas of friction when onboarding on to OCI bare metal and VM instance shapes for running **Generative AI workloads**:

1. **Challenges making hardware decisions**: Customers need guidance making hardware decisions (e.g. ideal networking and storage configuration for running an AI workload) and managing hardware costs efficiently. Currently, making these decisions is a painful exercise for data scientists and ML engineers. They spend several weeks narrowing down the best and most popular techniques. As the technical knowledge for Gen AI is limited in mainstream enterprise customers, our customers seek a default experience from cloud providers, which guides them through best practices and a happy path.
2. **Challenges making software stack decisions**: Data scientists and ML engineers today face difficulties selecting the appropriate software stack for their GPU workloads, which delays onboarding and monetization of OCI compute resources. ML Engineers need to select the right software packages and regularly update those packages to avoid compatibility issues. For example, when the OS automatically updates without updating the GPU drivers, packages like PyTorch may fail to communicate with CUDA drivers. The difficulty in selecting suitable models and optimization frameworks, such as deciding between TensorFlow and PyTorch for training or which quantization techniques to use for optimizing model size, further complicates the onboarding process.
3. **Observability and monitoring**: MLOps, infrastructure management and monitoring add another layer of complexity. Enterprises need to identify and deploy models on Kubernetes clusters with auto-scaling in production. After deploying the models, they need to monitor metrics like GPU usage, API calls, and throughput. Installation and management of tools like Prometheus, MLFlow, and Grafana for monitoring require Kubernetes expertise. Frequent technical issues related to Kubernetes deployment and management result in downtime, affecting productivity and time-to-market.

### What is Corrino and how does it help?

Corrino targets to deliver a no-code workload deployment workflow for the most popular Gen AI workloads by making hardware recommendations, OCI compute platform decisions, and software stack decisions for the customer.

1. **Validated hardware recommmendations for running common GenAI workloads**: First, Corrino provides pre-packaged recipes for running AI workloads with specific hardware recommendations. For example, a recipe for running cost-optimized inference could recommend Ampere A1 CPUs instead of H100 GPUs. These validated recommendations reduce the need for hardware experimentation and performance benchmarking, allowing enterprises to focus on their core business objectives rather than navigating complex hardware setups.
2. **Opinionated and pre-packaged software stack for one-click deployment of GenAI workloads to your GPUs**: To tackle challenges around the software stack, Corrino recipes come with a default, opinionated software stack tailored to the specific use case. For example, a recipe for running RAG would come pre-packaged with essential frameworks (e.g., LangChain), instruction-tuned models, embedding models, and vector DB connections. Once deployed, the user is provided API endpoints to run interface. This streamlining not only accelerates time-to-value but also minimizes compatibility issues and ongoing maintenance. Users can also customize certain attributes of recipes (e.g. changing node counts for inference). Users who need more control can use a custom template with basic pre-packaged software, enabling them to install their own frameworks and software.
3. **Out-of-the-box observability and easy auto-scaling for mission-critical workloads**: To address the third issue of MLOps and infrastructure management, Corrino automates these tasks based on user preferences. For example, Corrino allows users to select their preferred instance type and applies auto-scaling settings per best practices, which can be further customized. Also, necessary add-ons like Prometheus, Grafana, KEDA, and MLFlow are automatically installed by Corrino. Users can access these tools directly from the OCI console, simplifying the complex process of infrastructure management and monitoring.

### What are Recipes?

Recipes are not just terraform templates. Recipes provide the complete application stack with opinionated hardware recommendations, which have been validated by OCI and provide consistent, repeatable, and quick deployments of AI workloads with observability baked in.

We have published the following recipes which you can access once you install Corrino to your tenancy using this repo.
| Recipe | Description
|-----------|------
LLM Inference | LLM inference of Llama 2/3/3.1 7B/8B model inference single-node using NVIDIA Shapes & vLLM inference engine with auto-scaling using application metrics (e.g. inference latency)
Fine-Tuning Benchmarking | MLCommons Llama2 Quantized 70B Low-Rank Adaptation of Large Language Models (LORA) finetuning on A100
LoRA Fine-Tuning | LLM LoRA fine-tuning of custom model or open/closed access model from HuggingFace using any dataset.

### Recipe Configuration Options

When deploying recipes, you can configure:

1. LLM Model
2. GPU Shape
3. GPU Node Count
4. Auto-scaling settings (min replicas, max replicas, scaling criteria incl. application metrics like inference latency)
5. Fine-tuning hyperparameters (e.g. learning rate, number of epochs)
6. And more! Read more about recipe configuration and see sample recipe configurations [here](https://github.com/vishnukam3/oci-oke-ai-ml-sample-recipes/tree/main).

### What is in this repo?

The Corrino OKE Toolkit is a comprehensive collection of Terraform scripts which provisions the following resources:

1. An ATP database instance
2. Grafana and Prometheus for infrastructure monitoring
3. MLFlow for tracking experiment-level metrics
4. KEDA for dynamic auto-scaling based on AI/ML workload metrics rather than infrastructure metrics
5. Corrino’s front-end and back-end containers deployed to an OKE cluster of your choice

This combination provides a scalable, monitored environment optimized for easy deployment and management of AI/ML workloads. After installing this kit, you will be able to:

1. Access Corrino's portal and API
2. Deploy and undeploy an inference or training recipe using Corrino's portal or API
3. Deploy any container image for your AI/ML workloads by simply pointing to the container image

## Getting Started

In this "Getting Started" guide, we will walk you through 3 steps:

1. Installing Corrino in your tenancy and accessing Corrino's UI/API
2. Deploying and monitoring a Corrino recipe
3. Undeploying a recipe

### Pre-requisites

1. You must have an OKE cluster in your tenancy with the following configuration ([intructions for creating a new OKE cluster](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/create-cluster.htm))

| Configuration Field        | Value                                                                                              |
| -------------------------- | -------------------------------------------------------------------------------------------------- |
| Compartment                | Same as the compartment to which you are installing Corrino                                        |
| Kubernetes Version         | v1.31.1                                                                                            |
| Kubernetes API endpoint    | Public Endpoint                                                                                    |
| Node type                  | _No selection_                                                                                     |
| Kubernetes worker nodes    | Private workers                                                                                    |
| Shape and image            | Recommended: VM.Standard.E3.Flex; Minimum: Any other CPU shape (not validated by the Corrino team) |
| Select the number of OCPUs | Recommended: 6; Minimum: 1                                                                         |
| Amount of memory (GB)      | Recommended: 64; Minimum: 32                                                                       |
| Node Count                 | Recommended: 6; Minimum: 3                                                                         |
| Basic Cluster Confirmation | DO NOT select "Create a Basic cluster"                                                             |

2. Ensure GPUs are available in your region (this guide deploys an example recipe to a VM.GPU.A10.2 but you could deploy the recipes to other A10, A100, or H100 shapes as well with a simple recipe configuration change)
3. Create a compartment called `corrino` (instructions [here](https://docs.oracle.com/en-us/iaas/Content/Identity/compartments/To_create_a_compartment.htm)). If you do not have Admin rights, have a tenancy admin do the following: (1) create a compartment named `corrino` and (2) apply the policies in the "IAM Policies" section below inside the root compartment of your tenancy

### Step 1: Install and Access Corrino

1. Click on the “Deploy to Oracle Cloud” button below:

[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/oracle-quickstart/oci-corrino-oke-ai-ml-toolkit/releases/download/release-2025-01-27/release-2025-01-27.zip)

2. Follow the on-screen instructions on the Create Stack screen
3. Select “Run apply” in the “Review” section and click on Create
4. Monitor the deployment status by going to Resource Manager -> Stacks in OCI Console.
5. After the Job status changes to `Succeeded`, go to the Application Information tab under Stack Details in the OCI Console. Click on “Corrino API URL” button to access the Corrino API. Click on "Corrino Portal URL" to access the Corrino Portal.

### Step 2: Deploy a vLLM Inference recipe

1. Go to `<your-corrino-api-url>/deployment` from a web browser (you can find the Corrino API URL in the Application Information tab under Stack Details. See Step 1(5) above.)
2. Copy and paste this [sample inference recipe](https://github.com/vishnukam3/oci-oke-ai-ml-sample-recipes/blob/main/vllm_inference_sample_recipe.json) in the “Content:” text area and click “POST”
   **Important**: If you'd like to configure the recipe (e.g. the model you are deploying, to which shape, etc.) before deploying it, you can read the [recipe configuration documenation](https://github.com/vishnukam3/oci-oke-ai-ml-sample-recipes).
3. Check the deployment status by going to `<your-corrino-api-url>/deployment` in your web browser. Note down the `deployment ID`. Once the status changes to `monitoring`, you can proceed to the next step
4. Go to the `<your-corrino-api-url>/deployment_digests/<deployment_id>` in your web browser to find the endpoint URL (`digest.data.assigned_service_endpoint` field in the API response)
5. Test the recipe deployment by using the inference endpoint on Postman!
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
6. **Monitor the GPU node using Grafana**: Go to `<your-corrino-api-url>/workspaces` in your web browser. Go to the URL under the `add_ons.grafana.public_endpoint` field in the response JSON. You will find your Grafana username and password under OCI Console -> Select the correct region and compartment -> Resource Manager -> Stacks -> Open Corrino Installation Stack -> Application Information.

### Step 3: Undeploy the recipe

Undeploy the recipe to free up the GPU again by going to the `<your-corrino-api-url>/deployment_digests/<deployment_id>` in your web browswer and sending the following POST request:

```json
{
    “deployment_uuid”: “<deployment_id>”
}
```

### Additional Resources

Corrino API Documentation: Coming Soon

Corrino Sample recipes: https://github.com/vishnukam3/oci-oke-ai-ml-sample-recipes

## Features

| Feature              | Description                                                                                                                                                                                                                                                                                               | Instructions                              |
| -------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------- |
| Customizing Recipes  | Existing recipes provided by the Corrino team can be customized to fit your specific AI workload needs                                                                                                                                                                                                    | [Documentation](docs/customizing_recipes) |
| Shared Node Pool     | By default, infrastructure is provisioned and terminated with each Corrino recipe deployment. For workloads requiring longer-lived resources (e.g., Bare Metal machines), you can use shared node pools to deploy multiple recipes on shared infrastructure or keep resources running after undeployment. | [Documentation](docs/customizing_recipes) |
| File Storage Service | Use OCI's File Storage Service to store and supply the model weights for Corrino recipe deployments.                                                                                                                                                                                                      | [Documentation](docs/customizing_recipes) |
| Autoscaling          | Adjust the number of nodes in your deployment based on infrastructure and/or application metrics to prevent resource over utilization and under utilization.                                                                                                                                              | [Documentation](docs/customizing_recipes) |

## Ways to Access Corrino

Once Corrino has been deployed into your tenancy via Resource Manager, you can work with Corrino two ways:

**Option #1: API Access:**

1.  Inside the OCI Console > Resource Manager, select the stack you created for Corrino
2.  Go to "Variables" on the left-hand side under Resources section and copy the values for "corrino_admin_username" and "corrino_admin_nonce"
3.  Go to the "Application Information" tab under Stack Details
4.  Copy the "Corrino API URL" into your browser
5.  Upon first access, you must login - providing the "corrino_admin_username" for username and "corrino_admin_nonce" for password
6.  Now, you can view and access all API endpoints for your instance of Corrino

**Option #2: Corrino UI Portal (In Progress):**
For now, we recommend working with Corrino via the API server. An updated UI experience is being developed currently.

## IAM Policies

Many Corrino users choose to give full admin access to Corrino when using it for the first time or developing a POC, and making the permissions more granular overtime. We provide you with two different variations of IAM Policies for you to choose from - depending on your situation.

**Note:** `'Default'/'SecondUserGroup'` -> please modify this to match the user group that your user is in
**Note:** All these policies will be in the root compartment of your tenancy (NOT in the Corrino compartment itself)

**Option #1: Full Admin Access:**

```
Allow group 'Default'/'SecondUserGroup' to inspect all-resources in tenancy
Allow group 'Default'/'SecondUserGroup' to manage all-resources in compartment {comparment_name}
```

**Option #2: Fine-Grain Access:**

```
Allow group 'Default'/'SecondUserGroup' to inspect all-resources in tenancy

Allow group 'Default'/'SecondUserGroup' to manage instance-family in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to use subnets in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to manage virtual-network-family in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to use vnics in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to use network-security-groups in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to manage public-ips in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to manage cluster-family in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to manage orm-stacks in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to manage orm-jobs in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to manage vcns in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to manage subnets in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to manage internet-gateways in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to manage nat-gateways in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to manage route-tables in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to manage security-lists in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to inspect clusters in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to use cluster-node-pools in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to read cluster-work-requests in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to manage service-gateways in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to use cloud-shell in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to read vaults in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to read keys in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to use compute-capacity-reservations in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to read metrics in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to manage autonomous-database-family in compartment {compartment_name}

Allow dynamic-group 'Default'/'SecondUserGroup' to read virtual-network-family in compartment {compartment_name}

Allow dynamic-group 'Default'/'SecondUserGroup' to inspect compartments in compartment {compartment_name}

Allow dynamic-group 'Default'/'SecondUserGroup' to manage cluster-node-pools in compartment {compartment_name}
```

## Frequently asked questions

**What is a secure way for me to test Corrino out in my tenancy?**
Create a seperate compartment, create a new OKE cluster, and then deploy Corrino to the cluster.

**What containers and resources exactly get deployed to my tenancy when I deploy Corrino?**
Corrino’s installation Terraform deploys the following:

1. Corrino’s front-end and back-end containers
2. Grafana and Prometheus for infrastructure monitoring
3. MLFlow for tracking experiment-level metrics
4. KEDA for dynamic auto-scaling based on AI/ML workload metrics rather than infrastructure metrics

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

If you have an issue or a question, please contact Vishnu Kammari at vishnu.kammari@oracle.com or Grant Neuman at grant.neuman@oracle.com.
