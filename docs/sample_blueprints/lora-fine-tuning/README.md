# LoRA Fine-Tuning

This blueprint enables efficient model tuning using Low-Rank Adaptation (LoRA), a highly efficient method of LLM tuning. You can fine-tune a custom LLM or most open-source LLMs from Hugging Face. You can also use a custom dataset or any publicly available dataset from Hugging Face. Once the job is complete, results such as training metrics and logged in MLFlow for analysis. The fine-tuned model is then stored in an object storage bucket, ready for deployment.


## Pre-Filled Samples
| Title | Description|
|--------------------------------------------------|--------------------------------------------------------------------------------------------------------|
|Fine-Tune NousResearch/Meta-Llama-3.1-8B from Object Storage with Dataset from Hugging Face and Checkpoints saved in Object Storage (A10 VM)|Deploys Fine-Tune NousResearch/Meta-Llama-3.1-8B from Object Storage with Dataset from Hugging Face and Checkpoints saved in Object Storage (A10 VM) on VM.GPU.A10.2 with 2 GPU(s).|
|Fine-Tune NousResearch/Meta-Llama-3.1-8B from Object Storage with Dataset from Hugging Face on A10 VM|Deploys Fine-Tune NousResearch/Meta-Llama-3.1-8B from Object Storage with Dataset from Hugging Face on A10 VM on VM.GPU.A10.2 with 2 GPU(s).|
|Fine-Tune NousResearch/Meta-Llama-3.1-8B from Object Storage (PAR link) with Dataset from Hugging Face on A10 VM|Deploys Fine-Tune NousResearch/Meta-Llama-3.1-8B from Object Storage (PAR link) with Dataset from Hugging Face on A10 VM on VM.GPU.A10.2 with 2 GPU(s).|
|Fine-Tune meta-llama/Llama-3.2-1B-Instruct (Closed Model) from Hugging Face with Dataset from Hugging Face on A10 VM|Deploys Fine-Tune meta-llama/Llama-3.2-1B-Instruct (Closed Model) from Hugging Face with Dataset from Hugging Face on A10 VM on VM.GPU.A10.2 with 2 GPU(s).|
|Fine-Tune NousResearch/Meta-Llama-3.1-8B (Open Model) from Hugging Face with Dataset from Hugging Face on A10 VM|Deploys Fine-Tune NousResearch/Meta-Llama-3.1-8B (Open Model) from Hugging Face with Dataset from Hugging Face on A10 VM on VM.GPU.A10.2 with 2 GPU(s).|
