# Shared Node Pools

## What are they

When you deploy a recipe via Corrino, the underlying infrastructure is spun up (separate node pool for each recipe within the Corrino cluster) and the application layer is deployed on top of that infrastructure. Once you are done with recipe and undeploy it, the application layer and the infrastructure gets spun down (the node pool is deleted). This creates an issue when you want to quickly deploy and undeploy recipes onto infrastructure that requires a long recycle time (such as bare metal shapes) or you want to deploy multiple recipes onto the same underlying infrastructure (ex: recipe A uses 2 GPUs and recipe B uses 2 GPUs on a shape with 4 GPUs).

In come shared node pools, where you can launch infrastructure independent of a recipe. You can launch a shared node pool, and deploy/undeploy recipes onto the same node pool (underlying infrastructure) - removing the need to spin up new infrastructure for every recipe that is deployed.

## How to use them

You can create a shared node pool with a selector or without a selector. A selector is a naming convention that you can use to ensure specific recipes land on specific shared node pools.

### With selector

1. Create a shared node pool with a selector (this would be the payload to the `/deployment` POST API):

```
{
	"deployment_name": "MI300X shared pool",
	"recipe_mode": "shared_node_pool",
	"shared_node_pool_size": 1,
	"shared_node_pool_shape": "BM.GPU.MI300X.8",
	"shared_node_pool_boot_volume_size_in_gbs": 500,
	"shared_node_pool_selector": "selector_1"
}
```

2. Wait for the shared node pool to be deployed (can check `deployment_logs` for status)
3. Deploy any recipe that you want to be deployed on the BM.GPU.MI300x "selector_1" shared node pool (this would be the payload to the `/deployment` POST API):

```
{
	"recipe_id": "example",
	"recipe_mode": "service",
	"deployment_name": "echo2 seattle",
	"recipe_use_shared_node_pool": true,
	"recipe_shared_node_pool_selector": "selector_1",
	"recipe_image_uri": "hashicorp/http-echo",
	"recipe_container_command_args": [
	"-text=corrino"
	],
	"recipe_container_port": "5678",
	"recipe_node_shape": "BM.GPU.MI300X.8",
	"recipe_replica_count": 2
}
```

Note that the parameters:

- `recipe_use_shared_node_pool` ensures that we are using a shared node pool for this recipe (and not launching new infrastructure
- `recipe_shared_node_pool_selector` ensures that we are deploying this recipe onto the MI300x shared node pool we deployed in Step 1
- `recipe_node_shape` needs to match the shape of the shared node pool we launched in step 1 (regardless of including the selector or not)

\*\* If no shared node pool of shape BM.GPU.MI300X.8 with selector `selector_1` exisited, the recipe would wait to be deployed until that shared node pool was created

### Without Selector

1. Create a shared node pool without a selector (this would be the payload to the `/deployment` POST API):

```
{
	"deployment_name": "MI300X shared pool",
	"recipe_mode": "shared_node_pool",
	"shared_node_pool_size": 1,
	"shared_node_pool_shape": "BM.GPU.MI300X.8",
	"shared_node_pool_boot_volume_size_in_gbs": 500,
}
```

2. Wait for the shared node pool to be deployed (can check `deployment_logs` for status)
3. Deploy any recipe that you want to be deployed on the BM.GPU.MI300x "selector_1" shared node pool (this would be the payload to the `/deployment` POST API):

```
{
	"recipe_id": "example",
	"recipe_mode": "service",
	"deployment_name": "echo2 seattle",
	"recipe_use_shared_node_pool": true,
	"recipe_image_uri": "hashicorp/http-echo",
	"recipe_container_command_args": [
	"-text=corrino"
	],
	"recipe_container_port": "5678",
	"recipe_node_shape": "BM.GPU.MI300X.8",
	"recipe_replica_count": 2
}
```

Note that the parameters:

- `recipe_use_shared_node_pool` ensures that we are using a shared node pool for this recipe (and not launching new infrastructure
- `recipe_node_shape` needs to match the shape of the shared node pool we launched in step 1 (regardless of including the selector or not)

**This recipe will be deployed onto any BM.GPU.MI300X.8 shared node pool since no selector was included in the recipe**
**For example, if you had two BM.GPU.MI300X.8 shared node pools, then it will randomly select one for deployment**

## Considerations

- If you do not have a shared node pool deployed but try to deploy a recipe using the `recipe_use_shared_node_pool`, Corrino will wait to deploy the recipe until it has the shared node pool to launch the recipe onto
- Bare metal shape shared node pools require the `shared_node_pool_boot_volume_size_in_gbs` parameter
- Any recipe is compatible with shared node pools

## Sample Recipes

[shared_node_pool_A10_BM](../sample_recipes/shared_node_pool_A10_BM.json)
