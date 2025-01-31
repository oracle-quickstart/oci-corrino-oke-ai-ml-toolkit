# Auto-Scaling

Corrino manages [Horizontal Pod Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) (HPA) via [Kubernetes Event-driven Autoscaling](https://keda.sh) (KEDA). Currently, users can scale to more pods and nodes depending on load. This works for our vLLM inference recipe, and the doc below will serve as a setup guide.

## How it works:
Corrino uses Prometheus + vLLM metrics as the target to autoscale pods + nodes.
Prometheus scrapes vLLM for its metrics, and a KEDA ScaledObject stores a query and threshold value to decide when to scale. KEDA runs this query based on a time interval, and if the threshold is passed, the HPA will trigger a scale up. If, after some time, the number returns below the threshold, the HPA will trigger a scale down.

Smoothing factors have been added to both KEDA and HPA so that they are both responsive, but do not trigger immediate scaling based on an intermittent agressive spike in traffic.

## Considerations:
For each recipe, the user defines:
1. The number of GPUs per node required
2. The number of nodes
3. The number of recipe replicas to run

For autoscaling, this has implications. Consider the following recipe:
1. 1 GPU
2. 1 VM.GPU.A10.2
3. 1 replica

This recipe would occupy "1 slot" on a VM.GPU.A10.2. Therefore, it could effectively scale to 2 replicas in autoscaling without needing a new node. However, when it needs the third replica, it will either need a new node, or it will pend until a slot is free on the current GPU which provides no value in an autoscaling scenario.

Therefore, the following guidance is recommended:
1. Make the number of GPUs utilized by the recipe evenly divide into the total number of GPUs on the node. For example:
  - recipe requires 2 GPUs and shape has 4 GPUs so it could scale once before requiring a new node
  - recipe requires 2 GPUs and shape has 2 GPUs so each scale would require a new node
  - recipe requires 1 GPU and shape has 8 GPUs so it could scale 8 times before requiring a new node
2. Do not allow for more max replicas than can fit on max nodes. For example:
  - Max replicas for autoscaling is 8, but max nodes can only fit 4 replicas. Autoscaling will try to provision 8 replicas, but 4 will pend due to insufficient GPUs


## Basic Configurations:

|Param|Description|Example|
|:---:|:---:|:---:|
|min_replicas|Minimum number of replicas to start with|1|
|max_replicas|Maximum number of replicas to scale to|4|
|min_nodes|Minimum number of nodes in node pool|1|
|max_nodes|Maximum node pool size to scale to|4|

### Pod Auto-Scaling:
Define the min and max replicas a recipe can scale to, considering how many of your recipes could fit on a single node. Some examples below for single node recipes:

**Recipe GPU Count: 2, Recipe Shape: BM.GPU.H100.8**
4 replicas of this could fit on a single H100:
```json
{
    "recipe_pod_autoscaling_params": {
        "min_replicas": 1,
        "max_replicas": 4
    }
}
```

**Recipe GPU Count: 1, Recipe Shape: VM.GPU.A10.2**
2 replicas of this could fit on a single VM.GPU.A10.2:
```json
{
    "recipe_pod_autoscaling_params": {
        "min_replicas": 1,
        "max_replicas": 2
    }
}
```

Additionally, pod autoscaling can also be accompanied by [startup and liveness probes](../startup_liveness_probes/README.md) which verify that a recipe is ready to receive requests, and that a recipe is still "alive".

### Node + Pod Auto-Scaling:
Define the min and max replicas a recipe can scale to, considering how many max nodes you want to allow for, and how many of your recipes could fit on those nodes:

**Recipe GPU Count: 2, Recipe Shape: BM.GPU.H100.8**
4 replicas on first node, then 4 replicas on second node if scaling required:
```json
{
    "recipe_node_autoscaling_params": {
        "min_nodes": 1,
        "max_nodes": 2
    },
    "recipe_pod_autoscaling_params": {
        "min_replicas": 1,
        "max_replicas": 8
    }
}
```

**Recipe GPU Count: 1, Recipe Shape: VM.GPU.A10.2**
2 replicas on the first node, up to 4 total nodes for a total of 8 replicas:
```json
{
    "recipe_node_autoscaling_params": {
        "min_nodes": 1,
        "max_nodes": 4
    },
    "recipe_pod_autoscaling_params": {
        "min_replicas": 1,
        "max_replicas": 8
    }
}
```

## Example Recipe and Testing

The following [example_recipe](./example_recipe.json) shows a minimum basic example of how to use autoscaling with vLLM. Paste this in your deployment, and then post to launch the recipe.

Note, the `scaling_threshold` parameter here is intentionally set very low to kick off scaling at a lighter load. It is better to use the defaults.

Once the recipe is ready, follow the example steps to test autoscaling:

1. Get your workspace url. It will be everything after `api` in your deployment. So for example, my api endpoint is api.100-200-160-20.nip.io, so my workspace endpoint is `100-200-160-20.nip.io`. Using my endpoint, the vllm endpoint is the `deployment_name` from the `example_recipe.json` + my workspace endpoint, so:

`autoscalevllmexample.100-200-160-20.nip.io`

To test this is correct, run:
```bash
curl -L autoscalevllmexample.100-200-160-20.nip.io/metrics
```
Which will give you current metrics vLLM is reporting from your server.

2. Run the following to hit your endpoint with load:
```bash
# Note, python version must be 3.8 < python version < 3.11 for this tool.

git clone https://github.com/ray-project/llmperf.git && cd llmperf
git checkout 03872a48f7df06bb6760bf23d0d2c2784d7d9728
python3 -m venv venv
source venv/bin/activate
pip3 install -e .

# this is the vllm endpoint above, prefixed by https:// and with /v1
export OPENAI_API_BASE="https://autoscalevllmexample.100-200-160-20.nip.io/v1"
export OPENAI_API_KEY="test"
python3 token_benchmark_ray.py \
  --model "NousResearch/Meta-Llama-3.1-8B-Instruct" \
  --mean-input-tokens 512 \
  --mean-output-tokens 512 \
  --stddev-input-tokens 10 \
  --stddev-output-tokens 10 \
  --num-concurrent-requests 30 \
  --timeout 3600 \
  --max-num-completed-requests 3000 \
  --results-dir t \
  --llm-api openai
```

3. Advanced users can check the kubernetes cluster locally by watching `kubectl get pods` to see both node and pod autoscaling. Otherwise, go to the OKE cluster in the console, click node pools, and after a few minutes you'll see a new node pool appear. This new node pool creation typically appears between 8-10% on the llmperf completion bar you see in the terminal when launching the requests (based on the example recipe provided).

## Advanced Configuration
In addition to the basic configuration which should be sufficient for most users, additional parameters are tunable. The modification of these parameters has been tested, but each will impact scaling in a different way and should be used cautiously. All of these are part of `recipe_pod_autoscaling_params`:

|Param|Description|Example|
|:---:|:---:|:---:|
|scaling_cooldown|Min time to wait after scaling up before scaling back down (s)|60|
|polling_interval|How often to query scaling metric (s)|15|
|scaling_threshold|Threshold value to trigger scaling. If tuning, this will be most impactful on scaling. Moving it up will make scaling less aggressive, moving it down will make scaling more aggressive|0.5|
|query|If desired, a valid prometheus query to be used in conjunction with threshold to trigger scaling. Will completely change scaling behavior||