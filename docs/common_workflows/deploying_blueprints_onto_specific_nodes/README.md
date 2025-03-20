# Deploying Blueprints Onto Specific Nodes

**Note:** A basic understanding of how to use Kubernetes is required for this task

Assumption: the node exists and you are installing OCI AI Blueprints alongside this pre-existing node (i.e. the node is in the same cluster as the OCI AI Blueprints application)

## Label Nodes

As a first step, we will tell OCI AI Blueprints about the node by manually labeling them and turning it in a shared node pool. Make sure to have the node ip address.

Let's pretend I wanted to create the shared node pool named "a100pool". We will use this in the examples going forward.

```bash
kubectl label node <node_ip> corrino=a100pool
kubectl label node <node_ip> corrino/pool-shared-any=true
```

This will actually simulate the labels OCI AI Blueprints uses in a shared pool. If you want to add a second node to that same pool, you'd just add those labels to the next node following the same process.

## Deploy a blueprint

Now that you have artifically created a shared node pool using the node labels above, you can deploy a recipe to that node pool.

```json
{
  "recipe_id": "example",
  "recipe_mode": "service",
  "deployment_name": "a100 deployment",
  "recipe_use_shared_node_pool": true,
  "recipe_shared_node_pool_selector": "a100pool",
  "recipe_image_uri": "hashicorp/http-echo",
  "recipe_container_command_args": ["-text=corrino"],
  "recipe_container_port": "5678",
  "recipe_node_shape": "BM.GPU.A100-v2.8",
  "recipe_replica_count": 1,
  "recipe_nvidia_gpu_count": 4
}
```

Note: In the example above, we specified `recipe_nvidia_gpu_count` as 4 which means we want to use 4 of the GPUs on the node.

Note: We set `recipe_shared_node_pool_selector` to "a100pool" to match the name of the shared node pool we created with the exisiting node.

Note: We set `recipe_use_shared_node_pool` to true so that we are using the shared node mode behavior for the blueprint (previously called recipe).

## Complete

At this point, you have successfully deployed a blueprint to an exisiting node and utilized a portion of the existing node by specifiying the specific number of GPUs you wish to use for the blueprint.
