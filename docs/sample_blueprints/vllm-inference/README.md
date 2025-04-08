# LLM Inference with vLLM

This blueprint simplifies the deployment of LLMs using an open-source inference engine called vLLM. You can deploy a custom model or select from a variety of open-source models on Hugging Face.

The blueprint deploys the model from an object storage bucket to a GPU node in an OKE cluster in your tenancy. Once deployed, you receive a ready-to-use API endpoint to start generating responses from the model. For mission-critical workloads, you can also configure auto-scaling driven by application metrics like inference latency. To summarize, this blueprint streamlines inference deployment, making it easy to scale and integrate into your applications without deep, technical expertise.

## Pre-Filled Samples
| Title | Description|
|--------------------------------------------------|--------------------------------------------------------------------------------------------------------|
|Meta-Llama-3.1-8B-Instruct from OCI Object Storage on VM.GPU.A10.2 with vLLM|Deploys Meta-Llama-3.1-8B-Instruct from OCI Object Storage on VM.GPU.A10.2 with vLLM on VM.GPU.A10.2 with 2 GPU(s).|
|meta-llama/Llama-3.2-11B-Vision (Closed Model) from Hugging Face on VM.GPU.A10.2 with vLLM|Deploys meta-llama/Llama-3.2-11B-Vision (Closed Model) from Hugging Face on VM.GPU.A10.2 with vLLM on VM.GPU.A10.2 with 2 GPU(s).|
|NousResearch/Meta-Llama-3-8B-Instruct (Open Model) from Hugging Face on VM.GPU.A10.2 with vLLM|Deploys NousResearch/Meta-Llama-3-8B-Instruct (Open Model) from Hugging Face on VM.GPU.A10.2 with vLLM on VM.GPU.A10.2 with 2 GPU(s).|
|NousResearch/Meta-Llama-3-8B-Instruct (Open Model) from Hugging Face on VM.GPU.A10.2 with vLLM and Endpoint API Key|Deploys NousResearch/Meta-Llama-3-8B-Instruct (Open Model) from Hugging Face on VM.GPU.A10.2 with vLLM and Endpoint API Key on VM.GPU.A10.2 with 2 GPU(s).|
