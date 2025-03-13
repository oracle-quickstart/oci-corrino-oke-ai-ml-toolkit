# Custom Blueprints

## What are Custom Blueprints?

Customer Blueprints are community-contributed blueprints that meet your / your customers’ specific needs. Examples include: "RAG blueprint with 23ai integration" or an "Agentic Blueprint". You can also contribute pre-filled samples for existing blueprints. For example, you could add a pre-filled sample called "Inference of Llama-3-70B model on A100 with vLLM" to the "Inference with vLLM" blueprint. The custom blueprints that you contribute can be accessed by anyone using OCI AI Blueprints.

## Publishing Custom Blueprints: Step-by-Step Guide

1. Upload your custom blueprint's container image to a container registry. Make the container image public.
2. Create and test a pre-filled sample deployment (see Example Pre-Filled Sample below) on OCI AI Blueprints with your container image. See the Blueprint Schema below (pre_filled_samples field) for guidance on the fields you can pass to deploy your container image to OCI AI Blueprints. Validate the you are able to deploy the container image to OCI AI Blueprints without any issues.
3. Create the custom-blueprint.json in a way that aligns with the Blueprint Schema (see Blueprint Schema section below). Ideally the JSON has 2-3 pre-filled samples to simplify user onboarding.
4. Use a validator to test the JSON schema (e.g. https://www.jsonschemavalidator.net/).
5. Test the pre-filled samples on your own instance of OCI AI Blueprints.
6. Send the custom-blueprint.json file to OCI AI Blueprints team.
7. Submit changes to this GitHub repo with the new blueprint information. Submit changes via a pull request. All modifications will be reviewed by the OCI AI Blueprints team before being merged.

## Maintaining Custom Blueprints

- Update custom blueprints to align with the latest version of the blueprint schema
- Address GitHub issues related to your blueprints or samples
- Provide version history / backwards compatibility as needed

## Blueprint Schema

Version 1.0

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "blueprintSchema",
  "title": "Blueprint Schema",
  "description": "Use this schema for creating new blueprints or updating existing blueprints.",
  "type": "object",
  "properties": {
    "blueprint_title": {
      "type": "string",
      "description": "Title of the blueprint. Users see this in the portal and in GitHub docs."
    },
    "blueprint_short_description": {
      "type": "string",
      "description": "Short 100-150 character description of the blueprint. Users see this in the Blueprints List screen on the portal and in GitHub docs."
    },
    "blueprint_long_description": {
      "type": "string",
      "description": "Longer 250-500 word description of the blueprint. Users see this in the Blueprint Detail screen on the portal and in GitHub docs."
    },
    "pre_filled_samples": {
      "type": "array",
      "items": {
        "properties": {
          "recipe_id": {
            "type": "string",
            "description": "An identifier for your blueprint (e.g. llm_inference_nvidia)"
          },
          "pre_filled_sample_name": {
            "type": "string",
            "description": "Name of the pre-filled sample. Users see this name on the portal. Keep it short (7-20 words) and descriptive. (e.g. Inference of Llama-3-70B model on NVIDIA A100 GPUs with vLLM)"
          },
          "deployment_name": {
            "type": "string",
            "description": "Any deployment name to identify the deployment details easily. Must be unique from other blueprint deployments. For example: my-test-deployment-of-blueprint"
          },
          "recipe_mode": {
            "enum": ["service", "job", "shared_node_pool"],
            "description": "One of the following: service, job, or shared_node_pool. Enter service for inference blueprint deployments and job for fine-tuning blueprint deployments."
          },
          "recipe_replica_count": {
            "type": "integer",
            "description": "Number of replicas of the blueprint container pods to create. This feature is under development. Always enter 1."
          },
          "recipe_node_shape": {
            "type": "string",
            "description": "Enter the shape of the node that you want to deploy the blueprint on to. Example: BM.GPU.A10.4"
          },
          "recipe_node_pool_size": {
            "type": "integer",
            "description": "Number of nodes that you want to allocate for this blueprint deployment. Ensure you have sufficient capacity. This feature is under development. Always enter 1."
          },
          "recipe_use_shared_node_pool": {
            "type": "boolean",
            "description": "Indicate whether you want to use a shared node pool to deploy this (true) or if you want to provision a new node pool for this deployment (false)."
          },
          "recipe_shared_node_pool_selector": {
            "type": "string",
            "description": "..."
          },
          "recipe_node_boot_volume_size_in_gbs": {
            "type": "integer",
            "description": "Size of boot volume in GB for image. Recommend entering 500.???"
          },
          "recipe_node_selector_arch": {
            "type": "string",
            "description": "..."
          },
          "recipe_flex_shape_ocpu_count": {
            "type": "integer",
            "description": "..."
          },
          "recipe_flex_shape_memory_size_in_gbs": {
            "type": "integer",
            "description": "..."
          },
          "recipe_image_uri": {
            "type": "string",
            "description": "Location of the blueprint container image. Each blueprint points to a specific container image. See the blueprint.json examples below. Example: iad.ocir.io/iduyx1qnmway/corrino-devops-repository:vllmv0.6.2"
          },
          "recipe_container_command": {
            "type": "array",
            "items": {
              "type": "string"
            },
            "description": "..."
          },
          "recipe_container_command_args": {
            "type": "array",
            "items": {
              "type": "string"
            },
            "description": "Container init arguments to pass. Each blueprint has specific container arguments that it expects. See the Blueprint Arguments section below for details. Example: [\"--model\",\"$(Model_Path)\",\"--tensor-parallel-size\",\"$(tensor_parallel_size)\"]"
          },
          "recipe_container_env": {
            "type": "array",
            "items": {
              "additionalProperties": false,
              "required": ["key", "value"],
              "properties": {
                "key": {
                  "type": "string"
                },
                "value": {
                  "type": ["integer", "string"]
                }
              }
            },
            "description": "Values of the blueprint container init arguments. Example: [{\"key\": \"tensor_parallel_size\",\"value\": \"2\"},{\"key\": \"model_name\",\"value\": \"NousResearch/Meta-Llama-3.1-8B-Instruct\"},{\"key\": \"Model_Path\",\"value\": \"/models/NousResearch/Meta-Llama-3.1-8B-Instruct\"}]"
          },
          "recipe_node_autoscaling_params": {
            "type": "object",
            "properties": {
              "min_nodes": {
                "type": "integer",
                "description": "Minimum number of nodes in node pool"
              },
              "max_nodes": {
                "type": "integer",
                "description": "Maximum node pool size to scale to"
              }
            },
            "additionalProperties": false,
            "examples": [
              {
                "min_nodes": 1,
                "max_nodes": 2
              }
            ]
          },
          "recipe_pod_autoscaling_params": {
            "type": "object",
            "properties": {
              "min_replicas": {
                "type": "integer",
                "description": "Minimum number of replicas to start with"
              },
              "max_replicas": {
                "type": "integer",
                "description": "Minimum number of replicas to start with"
              },
              "scaling_metric": { "type": "string", "description": "..." },
              "collect_metrics_timespan": {
                "type": "string",
                "description": "Minimum number of replicas to start with"
              },
              "scaling_threshold": {
                "type": "number",
                "description": "Threshold value to trigger scaling. If tuning, this will be most impactful on scaling. Moving it up will make scaling less aggressive, moving it down will make scaling more aggressive"
              },
              "scaling_cooldown": {
                "type": "integer",
                "description": "Min time to wait after scaling up before scaling back down (s)"
              },
              "polling_interval": {
                "type": "integer",
                "description": "How often to query scaling metric (s)"
              },
              "stabilization_window_down": {
                "type": "integer",
                "description": "Time period over which to stabilize metrics before scaling a pod down (s)"
              },
              "scaling_period_down": {
                "type": "integer",
                "description": "Min time after scaling a pod down before it can scale another pod down"
              },
              "stabilization_window_up": {
                "type": "integer",
                "description": "Time period over which to stabilize metrics before scaling a pod up (s)"
              },
              "scaling_period_up": {
                "type": "integer",
                "description": "Min time after scaling a pod up before another pod can be added"
              },
              "query": {
                "type": "string",
                "description": "If desired, a valid prometheus query to be used in conjunction with threshold to trigger scaling. Will completely change scaling behavior"
              },
              "scaler_type": {
                "type": "string",
                "enum": ["prometheus"],
                "description": "..."
              },
              "server_address": { "type": "string" }
            },
            "additionalProperties": false,
            "examples": [
              {
                "min_replicas": 4,
                "max_replicas": 8,
                "scaling_metric": "e2e_request_latency_seconds_bucket",
                "collect_metrics_timespan": "1m",
                "scaling_threshold": 0.6,
                "scaling_cooldown": 60,
                "polling_interval": 15,
                "stabilization_window_down": 180,
                "scaling_period_down": 90,
                "stabilization_window_up": 120,
                "scaling_period_up": 60,
                "query": "1 - (sum(rate(vllm:e2e_request_latency_seconds_bucket{le='5.0', instance='recipe-vllmautowithfss.default:80'}[1m])) / sum(rate(vllm:e2e_request_latency_seconds_bucket{le='+Inf', instance='recipe-vllmautowithfss.default:80'}[1m])))",
                "scaler_type": "prometheus",
                "server_address": "http://prometheus-server.cluster-tools.svc.cluster.local"
              }
            ]
          },
          "recipe_liveness_probe_params": {
            "type": "object",
            "properties": {
              "failure_threshold": { "type": "number" },
              "endpoint_path": { "type": "string" },
              "port": { "type": "integer" },
              "scheme": { "type": "string" },
              "initial_delay_seconds": { "type": "number" },
              "period_seconds": { "type": "number" },
              "success_threshold": { "type": "integer" },
              "timeout_seconds": { "type": "number" }
            },
            "additionalProperties": false,
            "description": "If desired, a valid prometheus query to be used in conjunction with threshold to trigger scaling. Will completely change scaling behavior"
          },
          "recipe_startup_probe_params": {
            "type": "object",
            "properties": {
              "failure_threshold": { "type": "number" },
              "endpoint_path": { "type": "string" },
              "port": { "type": "integer" },
              "scheme": { "type": "string" },
              "initial_delay_seconds": { "type": "number" },
              "period_seconds": { "type": "number" },
              "success_threshold": { "type": "integer" },
              "timeout_seconds": { "type": "number" }
            },
            "additionalProperties": false,
            "description": "If desired, a valid prometheus query to be used in conjunction with threshold to trigger scaling. Will completely change scaling behavior"
          },
          "recipe_container_port": {
            "type": "string",
            "description": "Required for inference blueprint deployments. Inference endpoint will point to this port."
          },
          "recipe_container_command_use_shell": {
            "type": "boolean",
            "description": " "
          },
          "recipe_nvidia_gpu_count": {
            "type": "integer",
            "description": "Number of GPUs within the node that you want to deploy the blueprint's artifacts on to. Must be greater than 0. Must be less than the total number of GPUs available in the node shape. For example, VM.GPU.A10.2 has 2 GPUs, so this parameter cannot exceed 2 if the recipe_node_shape is VM.GPU.A10.2."
          },
          "recipe_amd_gpu_count": {
            "type": "integer",
            "description": " "
          },
          "recipe_shared_memory_volume_size_limit_in_mb": {
            "type": "integer",
            "description": " "
          },
          "recipe_ephemeral_storage_size": {
            "type": "integer",
            "description": "Ephemeral (will be deleted) storage in GB to add to node. If pulling large models from huggingface directly, set this value to be reasonably high. Cannot be higher than boot_volume_size."
          },
          "recipe_container_memory_size": {
            "type": "integer",
            "description": " "
          },
          "input_object_storage": {
            "type": "array",
            "items": {
              "additionalProperties": false,
              "oneOf": [
                {
                  "required": ["par", "mount_location", "volume_size_in_gbs"]
                },
                {
                  "required": [
                    "bucket_name",
                    "mount_location",
                    "volume_size_in_gbs"
                  ]
                }
              ],
              "properties": {
                "par": {
                  "type": "string"
                },
                "bucket_name": {
                  "type": "string"
                },
                "mount_location": {
                  "type": "string"
                },
                "volume_size_in_gbs": {
                  "type": "integer"
                },
                "include": {
                  "type": "array",
                  "items": {
                    "type": "string"
                  }
                },
                "exclude": {
                  "type": "array",
                  "items": {
                    "type": "string"
                  }
                }
              }
            },
            "description": "Name of bucket to mount at location “mount_location”. Mount size will be volume_size_in_gbs. Will copy all objects in bucket to mount location. Store your LLM model (and in the case of fine-tuning blueprints, your input dataset as well) in this bucket. Example: [{\"bucket_name\": \"corrino_hf_oss_models\", \"mount_location\": \"/models\", \"volume_size_in_gbs\": 500}]"
          },
          "input_file_system": {
            "type": "array",
            "items": {
              "additionalProperties": false,
              "required": [
                "file_system_ocid",
                "mount_target_ocid",
                "mount_location",
                "volume_size_in_gbs"
              ],
              "properties": {
                "file_system_ocid": {
                  "type": "string"
                },
                "mount_target_ocid": {
                  "type": "string"
                },
                "mount_location": {
                  "type": "string"
                },
                "volume_size_in_gbs": {
                  "type": "integer"
                }
              }
            },
            "description": " "
          },
          "output_object_storage": {
            "type": "array",
            "items": {
              "additionalProperties": false,
              "required": [
                "bucket_name",
                "mount_location",
                "volume_size_in_gbs"
              ],
              "properties": {
                "bucket_name": {
                  "type": "string"
                },
                "mount_location": {
                  "type": "string"
                },
                "volume_size_in_gbs": {
                  "type": "integer"
                }
              }
            },
            "description": "Required for fine-tuning deployments. Name of bucket to mount at location “mount_location”. Mount size will be “volume_size_in_gbs”. Will copy all items written here during program runtime to bucket on program completion. Example: [{“bucket_name”: “output”,“mount_location”: “/output”,“volume_size_in_gbs”: 500}]"
          },
          "service_endpoint_domain": {
            "type": "string",
            "description": "Required for inference blueprint deployments. Inference endpoint will point to this domain."
          },
          "service_endpoint": {
            "type": "object",
            "properties": {
              "domain": {
                "type": "string"
              },
              "dedicated_load_balancer": {
                "type": "boolean"
              }
            },
            "description": " "
          },
          "shared_node_pool_selector": {
            "type": "string",
            "description": " "
          },
          "shared_node_pool_size": {
            "type": "integer",
            "description": " "
          },
          "shared_node_pool_shape": {
            "type": "string",
            "description": " "
          },
          "shared_node_pool_boot_volume_size_in_gbs": {
            "type": "integer",
            "description": " "
          },
          "shared_node_pool_flex_shape_memory_size_in_gbs": {
            "type": "integer",
            "description": " "
          },
          "shared_node_pool_flex_shape_ocpu_count": {
            "type": "integer",
            "description": " "
          },
          "shared_node_pool_mig_config": {
            "type": "string",
            "description": " "
          },
          "skip_capacity_validation": {
            "type": "boolean",
            "description": "Determines whether validation checks on shape capacity are performed before initiating deployment. If your deployment is failing validation due to capacity errors but you believe this not to be true, you should set skip_capacity_validation to be true in the blueprint JSON to bypass all checks for Shape capacity. Otherwise, this property should be set to false."
          },
          "skip_quota_validation": {
            "type": "boolean",
            "description": "Determines whether validation checks on shape quotas are performed before initiating deployment. If your deployment is failing validation due to quota issues but you believe this not to be true, you should set skip_quota_validation to be true in the blueprint JSON to bypass all checks for quotas. Otherwise, this property should be set to false."
          }
        },
        "required": ["recipe_mode", "deployment_name"],
        "additionalProperties": false
      },
      "description": "Pre-filled samples of blueprints."
    }
  }
}
```

## Example Pre-Filled Sample

```json
{
  "recipe_id": "llm_inference_nvidia",
  "recipe_mode": "service",
  "deployment_name": "vLLM Inference Deployment",
  "recipe_image_uri": "iad.ocir.io/iduyx1qnmway/corrino-devops-repository:vllmv0.6.2",
  "recipe_node_shape": "VM.GPU.A10.2",
  "input_object_storage": [
    {
      "par": "https://objectstorage.us-ashburn-1.oraclecloud.com/p/IFknABDAjiiF5LATogUbRCcVQ9KL6aFUC1j-P5NSeUcaB2lntXLaR935rxa-E-u1/n/iduyx1qnmway/b/corrino_hf_oss_models/o/",
      "mount_location": "/models",
      "volume_size_in_gbs": 500,
      "include": ["NousResearch/Meta-Llama-3.1-8B-Instruct"]
    }
  ],
  "recipe_container_env": [
    {
      "key": "tensor_parallel_size",
      "value": "2"
    },
    {
      "key": "model_name",
      "value": "NousResearch/Meta-Llama-3.1-8B-Instruct"
    },
    {
      "key": "Model_Path",
      "value": "/models/NousResearch/Meta-Llama-3.1-8B-Instruct"
    }
  ],
  "recipe_replica_count": 1,
  "recipe_container_port": "8000",
  "recipe_nvidia_gpu_count": 2,
  "recipe_node_pool_size": 1,
  "recipe_node_boot_volume_size_in_gbs": 200,
  "recipe_container_command_args": [
    "--model",
    "$(Model_Path)",
    "--tensor-parallel-size",
    "$(tensor_parallel_size)"
  ],
  "recipe_ephemeral_storage_size": 100,
  "recipe_shared_memory_volume_size_limit_in_mb": 200
}
```
