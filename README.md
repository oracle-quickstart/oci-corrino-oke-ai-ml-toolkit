# Multi-Node Inference

[Jump to Quickstart](#Quickstart_Guide:_Multi-Node_Inference)

## What is it?

Multi-node inference refers to distributing the workload of running inference for LLM models across multiple nodes, each equipped with one or more GPUs. This approach combines tensor parallelism—splitting the model across multiple GPUs within a node—and pipeline parallelism—spreading the workload across several nodes—to efficiently utilize available hardware resources.

## When to use it?

Use multi-node inference whenever you are trying to use a very large model that will not fit into a single node and the GPUs on that one node. Example would be _Meta Llama 3.1 405B_ or _DeepSeek-V3_ which is too large to fit onto a single node (and the GPUs within that one node). You must distribute the model weights across the GPUs of each node (tensor parallelism) and the GPUs in other nodes (pipeline parallelism) in order to run LLM inference with such large models.

## How to use it?

We are using [vLLM](https://docs.vllm.ai/en/latest/serving/distributed_serving.html) and [KubeRay](https://github.com/ray-project/kuberay?tab=readme-ov-file) which is the Kubernetes operator for [Ray applications](https://github.com/ray-project/ray).

In order to use multi-node inference in an OCI Blueprint, use the following recipe as a starter: [LINK](../sample_recipes/multinode_inference_VM_A10.json)

The recipe creates a RayCluster which is made up of one head node and worker nodes. The head node is identical to other worker nodes (in terms of ability to run workloads on it), except that it also runs singleton processes responsible for cluster management.

More documentation on RayCluster terminology [here](https://docs.ray.io/en/latest/cluster/key-concepts.html#ray-cluster).

## Required Recipe Parameters

The following parameters are required:

- `"recipe_mode": "raycluster"` -> recipe_mode must be set to raycluster

- `recipe_container_port` -> the port to access the inference endpoint

- `deployment_name`

- `recipe_node_shape`

- `input_object_storage` (plus the parameters required inside this object)

- `recipe_node_pool_size` -> the number of physical nodes to launch (will be equal to `num_worker_nodes` plus 1 for the head node)

- `recipe_node_boot_volume_size_in_gbs`

- `recipe_ephemeral_storage_size`

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

## Requirements

- **Same shape for worker and head nodes** = Cluster must be uniform in regards to node shape and size (same shape, number of GPUs, number of CPUs etc.) for the worker nodes and head nodes.

- **Chosen shape must have GPUs** = no CPU inferencing is available at the moment

- Only job supported right now using Ray cluster and OCI Blueprints is vLLM Distributed Inference. This will change in the future.

## Interacting with Ray Cluster

Once the multi-node inference recipe has been successfully deployed, you will have access to the following URLs:

1. **Ray Dashboard:** Ray provides a web-based dashboard for monitoring and debugging Ray applications. The visual representation of the system state, allows users to track the performance of applications and troubleshoot issues.
   **To find the URL for the API Inference Endpoint:** Go to `workspace` API endpoint and the URL will be under "recipes" object. The object will be labeled `<deployment_name>-raycluster-dashboard`. The format for the URL is `<deployment_name>.<assigned_service_endpoint>.com`
   **Example URL:** `https://dashboard.rayclustervmtest10.132-226-50-64.nip.io`

2. **API Inference Endpoint:** This is the API endpoint you will use to do inferencing across the multiple nodes. It follow the [OpenAI API spec](https://platform.openai.com/docs/api-reference/introduction)
   **To find the URL for the API Inference Endpoint:** Go to `workspace` API endpoint and the URL will be under "recipes" object. The object will be labeled `<deployment_name>-raycluster-app`. The format for the URL is `<deployment_name>.<assigned_service_endpoint>.com`
   **Example curl command:** `curl --request GET --location 'rayclustervmtest10.132-226-50-64.nip.io/v1/models'`

# Quickstart Guide: Multi-Node Inference

Follow these 6 simple steps to deploy your multi-node RayCluster using Corrino.

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
2. **Deploy the Recipe via Corrino**
   - Deploy the recipe json via the `deployment` POST API
3. **Monitor Your Deployment**
   - Check deployment status using Corrino’s logs via the `deployment_logs` API endpoint
4. **Verify Cluster Endpoints**

   - Once deployed, locate your service endpoints:
     - **Ray Dashboard:** Typically available at `https://dashboard.<deployment_name>.<assigned_service_endpoint>.com`
     - **API Inference Endpoint:** Accessible via `https://dashboard.<deployment_name>.<assigned_service_endpoint>.com`
   - Use these URLs to confirm that the cluster is running and ready to handle inference requests.

5. **Start Inference and Scale as Needed**
   - Test your deployment by sending a sample API request:
     ```bash
     curl --request GET --location 'https://dashboard.<deployment_name>.<assigned_service_endpoint>.com/v1/models'
     ```

Happy deploying!
