# Multi-Node Inference

[Jump to Quickstart](#Quickstart_Guide:_Multi-Node_Inference)

## What is it?

**Inference:**  
Inference is the process of running data through a trained machine learning model to generate an output—similar to calling a function with some input data and receiving a computed result. For instance, when you feed text (such as a question) into a large language model, the model processes that input and returns a text-based answer.

**Inference Serving:**  
Inference serving is about deploying these trained models as APIs or services. This setup allows for efficient processing of predictions, whether on demand (real-time) or in batches, much like how a web service handles requests and responses.

**Multi-Node Inference:**  
Multi-node inference scales up this process by distributing the workload across several computing nodes, each typically equipped with one or more GPUs. This is particularly useful for handling large models that require substantial computational power. It combines two key parallelization techniques:

- **Tensor Parallelism:** Within a single node, the model’s complex numerical operations (e.g., matrix multiplications) are divided among multiple GPUs. Think of it as breaking a large calculation into smaller pieces that can be processed simultaneously by different GPUs.
- **Pipeline Parallelism:** The inference process is divided into sequential stages, with each node responsible for one stage. This is similar to an assembly line, where each node completes a specific part of the overall task before passing it along.

Together, these methods ensure that multi-node inference efficiently utilizes available hardware resources, reducing processing time and improving throughput for both real-time and batch predictions.

## When to use it?

Use multi-node inference whenever you are trying to use a very large model that will not fit into all available GPU memory on a single node. As an example, Llama-3.3-70B-Instruct requires roughly 150G of GPU memory when serving. If you were serving this on BM.GPU.A10.4, the 4 A10 GPUs have a combined 100G of GPU memory, so the model is too large to fit onto this one node. You must distribute the model weights across the GPUs of each node (tensor parallelism) and the GPUs in other nodes (pipeline parallelism) in order to run LLM inference with such large models.

## How to determine shape and GPU requirements for a given model?

1. Find the number of parameters in your model (usually in the name of the model such as Llama-3.3-70B-Instruct would have 70 billion parameters)
2. Determine the precision of the model (FP32 vs FP16 vs FP8) - you can find this in the config.json of the model if on hugging face (look for the torch_dtype); a good assumption is that the model was trained on FP32 and is served on FP16 so FP16 is what you would use for your model precision
3. Use formula here: https://ksingh7.medium.com/calculate-how-much-gpu-memory-you-need-to-serve-any-llm-67301a844f21 or https://www.substratus.ai/blog/calculating-gpu-memory-for-llm to determine the amount of GPU memory needed
4. Determine which shapes you have access to and how much GPU memory each instance of that shape has: https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm (ex: VM.GPU2.1 has 16 GB of GPU memory per instance). Note that as of right now, you must use the same shape across the entire node pool when using multi-node inference. Mix and match of shape types is not supported within the node pool used for the multi-node inference recipe.
5. Divide the total GPU memory size needed (from Step #3) by the amount of GPU memory per instance of the shape you chose in Step #4. Round up to the nearest whole number. This will be the total number of nodes you will need in your node pool for the given shape and model.

## How to use it?

We are using [vLLM](https://docs.vllm.ai/en/latest/serving/distributed_serving.html) and [KubeRay](https://github.com/ray-project/kuberay?tab=readme-ov-file) which is the Kubernetes operator for [Ray applications](https://github.com/ray-project/ray).

In order to use multi-node inference in an OCI Blueprint, use the following recipe as a starter: [LINK](../sample_recipes/multinode_inference_VM_A10.json)

The recipe creates a RayCluster which is made up of one head node and worker nodes. The head node is identical to other worker nodes (in terms of ability to run workloads on it), except that it also runs singleton processes responsible for cluster management.

More documentation on RayCluster terminology [here](https://docs.ray.io/en/latest/cluster/key-concepts.html#ray-cluster).

## Required Recipe Parameters

The following parameters are required:

- `"recipe_mode": "raycluster"` -> recipe_mode must be set to raycluster

- `recipe_container_port` -> the port to access the inference endpoint

- `deployment_name` -> name of this deployment

- `recipe_node_shape` -> OCI name of the Compute shape chosen (use exact names as found here: https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm)

- `input_object_storage` (plus the parameters required inside this object)

- `recipe_node_pool_size` -> the number of physical nodes to launch (will be equal to `num_worker_nodes` plus 1 for the head node)

- `recipe_node_boot_volume_size_in_gbs` -> size of boot volume for each node launched in the node pool (make sure it is at least 1.5x the size of your model)

- `recipe_ephemeral_storage_size` -> size of the attached block volume that will be used to store the model for reference by each node (make sure it is at least 1.5x the size of your model)

- `recipe_nvidia_gpu_count` -> the number of GPUs per node (since head and worker nodes are identical, it is the number of GPUs in the shape you have specified. Ex: VM.GPU.A10.2 would have 2 GPUs)

- `"recipe_raycluster_params"` object -> which includes the following properties:

- `model_path_in_container` : the file path to the model in the container

- `head_node_num_cpus` : the number of OCPUs allocated to the head node (must match `worker_node_num_cpus`)

- `head_node_num_gpus` : the number of GPUs allocated the head node (must match `worker_node_num_gpus`)

- `head_node_cpu_mem_in_gbs` : the amount of CPU memory allocated to the head node (must match `worker_node_cpu_mem_in_gbs`)

- `num_worker_nodes` : the number of worker nodes you want to deploy (must be equal to `recipe_node_pool_size` - 1)

- `worker_node_num_cpus` : the number of OCPUs allocated to the head node (must match `head_node_num_cpus`)

- `worker_node_num_gpus` : the number of GPUs allocated the head node (must match `head_node_num_gpus`)

- `worker_node_cpu_mem_in_gbs` : the amount of CPU memory allocated to the head node (must match `head_node_cpu_mem_in_gbs`)

- [OPTIONAL] `redis_port` : the port to use for Redis inside the cluster (default is 6379)

- [OPTIONAL] `dashboard_port` : port on which the Ray dashboard will be available on inside the cluster (default is 8265)

- [OPTIONAL] `metrics_export_port`: port where metrics are exposed from inside the cluster (default is 8080)

- [OPTIONAL] `rayclient_server_port`: Ray client server port for external connections (default is 10001)

- [OPTIONAL] `head_image_uri`: Container image for the head node of the ray cluster (default is `vllm/vllm-openai:v0.7.2`)

- [OPTIONAL] `worker_image_uri`: Container image for the worker nodes of the ray cluster (default is `vllm/vllm-openai:v0.7.2`)

- [OPTIONAL] `rayjob_image_uri`: Container image for the K8s Job that is applied after the head and worker nodes are in ready state (in the future, we will change this to be a RayJob CRD but are using K8s Job for now) (default is `vllm/vllm-openai:v0.7.2`)

## Requirements

- **Kuberay Operator Installed** = Make sure that the kuberay operator is installed (this is installed via the Resource Manager if the Kuberay option is selected - default is selected). Any OCI AI Blueprints installation before 2/24/25 will need to be reinstalled via the latest quickstarts release in order to ensure Kuberay is installed in your OCI AI Blueprints instance.

- **Same shape for worker and head nodes** = Cluster must be uniform in regards to node shape and size (same shape, number of GPUs, number of CPUs etc.) for the worker nodes and head nodes.

- **Chosen shape must have GPUs** = no CPU inferencing is available at the moment

- Only job supported right now using Ray cluster and OCI Blueprints is vLLM Distributed Inference. This will change in the future.

- All nodes in the multi-node inferencing recipe's node pool will be allocated to Ray (subject to change). You cannot assign just a portion; the entire node pool is reserved for the Ray cluster.

## Interacting with Ray Cluster

Once the multi-node inference recipe has been successfully deployed, you will have access to the following URLs:

1. **Ray Dashboard:** Ray provides a web-based dashboard for monitoring and debugging Ray applications. The visual representation of the system state, allows users to track the performance of applications and troubleshoot issues.
   **To find the URL for the API Inference Endpoint:** Go to `workspace` API endpoint and the URL will be under "recipes" object. The object will be labeled `<deployment_name>-raycluster-dashboard`. The format for the URL is `<deployment_name>.<assigned_service_endpoint>.com`
   **Example URL:** `https://dashboard.rayclustervmtest10.132-226-50-64.nip.io`

2. **API Inference Endpoint:** This is the API endpoint you will use to do inferencing across the multiple nodes. It follows the [OpenAI API spec](https://platform.openai.com/docs/api-reference/introduction)
   **To find the URL for the API Inference Endpoint:** Go to `workspace` API endpoint and the URL will be under "recipes" object. The object will be labeled `<deployment_name>-raycluster-app`. The format for the URL is `<deployment_name>.<assigned_service_endpoint>.com`
   **Example curl command:** `curl --request GET --location 'rayclustervmtest10.132-226-50-64.nip.io/v1/models'`

# Quickstart Guide: Multi-Node Inference

Follow these 6 simple steps to deploy your multi-node RayCluster using OCI AI Blueprints.

1. **Create Your Deployment Recipe**
   - Create a JSON configuration (recipe) that defines your RayCluster. Key parameters include:
     - `"recipe_mode": "raycluster"`
     - `deployment_name`, `recipe_node_shape`, `recipe_container_port`
     - `input_object_storage` (and its required parameters)
     - `recipe_node_pool_size` (head node + worker nodes)
     - `recipe_nvidia_gpu_count` (GPUs per node)
     - A nested `"recipe_raycluster_params"` object with properties like `model_path_in_container`, `head_node_num_cpus`, `head_node_num_gpus`, `head_node_cpu_mem_in_gbs`, `num_worker_nodes`, etc.
   - Refer to the [sample recipe for parameter value examples](../sample_recipes/multinode_inference_VM_A10.json)
   - Refer to the [Required Recipe Parameters](#Required_Recipe_Parameters) section for full parameter details.
   - Ensure that the head and worker nodes are provisioned uniformly, as required by the cluster’s configuration.
2. **Deploy the Recipe via OCI AI Blueprints**
   - Deploy the recipe json via the `deployment` POST API
3. **Monitor Your Deployment**
   - Check deployment status using Corrino’s logs via the `deployment_logs` API endpoint
4. **Verify Cluster Endpoints**

   - Once deployed, locate your service endpoints:
     - **Ray Dashboard:** Typically available at `https://dashboard.<deployment_name>.<assigned_service_endpoint>.com`
     - **API Inference Endpoint:** Accessible via `https://<deployment_name>.<assigned_service_endpoint>.com`
   - Use these URLs to confirm that the cluster is running and ready to handle inference requests.

5. **Start Inference and Scale as Needed**
   - Test your deployment by sending a sample API request:
     ```bash
     curl --request GET --location 'https://dashboard.<deployment_name>.<assigned_service_endpoint>.com/v1/models'
     ```

Happy deploying!
