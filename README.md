# OCI AI Blueprints
**Deploy, scale, and monitor AI workloads with the OCI AI Blueprints platform, and reduce your GPU onboarding time from weeks to minutes.**

OCI AI Blueprints is a streamlined, no-code solution for deploying and managing Generative AI workloads on Kubernetes Engine (OKE). By providing opinionated hardware recommendations, pre-packaged software stacks, and out-of-the-box observability tooling, OCI AI Blueprints helps you get your AI applications running quickly and efficiently—without wrestling with the complexities of infrastructure decisions, software compatibility, and MLOps best practices.

[![Install OCI AI Blueprints](https://raw.githubusercontent.com/oracle-quickstart/oci-ai-blueprints/9d1d61b3b79e61dabe19d1672c3e54704b294a93/docs/install.svg)](./GETTING_STARTED_README.md)

## Table of Contents
**Getting Started**
- [Install AI Blueprints](./GETTING_STARTED_README.md)
- [Access AI Blueprints Portal and API](./docs/api_documentation/accessing_oci_ai_blueprints/README.md)

**About OCI AI Blueprints**
- [What is OCI AI Blueprints?](./docs/about/README.md#what-is-oci-ai-blueprints)
- [Why use OCI AI Blueprints?](./docs/about/README.md#why-use-oci-ai-blueprints)
- [Features](./docs/about/README.md#features)
- [List of Blueprints](./docs/about/README.md#frequently-asked-questions-faq)
- [FAQ](./docs/about/README.md#frequently-asked-questions-faq)
- [Support & Contact](https://github.com/oracle-quickstart/oci-ai-blueprints/blob/vkammari/doc_improvements/docs/about/README.md#frequently-asked-questions-faq)

**API Reference**
- [API Reference Documentation](docs/api_documentation/README.md)

**Additional Resources**
- [Publish Custom Blueprints](./docs/custom_blueprints)
- [Installing Updates](./docs/installing_new_updates)
- [IAM Policies](./docs/iam_policies/README.md)
- [Repository Contents](./docs/about/README.md#repository-contents)
- [Known Issues](docs/known_issues/README.md)

## Blueprints

Blueprints go beyond basic Terraform templates. Each blueprint:
- Offers validated hardware suggestions (e.g., optimal shapes, CPU/GPU configurations),
- Includes end-to-end application stacks customized for different GenAI use cases, and
- Comes with monitoring, logging, and auto-scaling configured out of the box.

After you install OCI AI Blueprints to an OKE cluster in your tenancy, you can deploy these pre-built blueprints:

| Blueprint                    | Description                                                                                                                             |
| ---------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------|
| **LLM Inference with vLLM**  | Deploy Llama 2/3/3.1 7B/8B models using NVIDIA GPU shapes and the vLLM inference engine with auto-scaling.                              |
| **Fine-Tuning Benchmarking** | Run MLCommons quantized Llama-2 70B LoRA finetuning on A100 for performance benchmarking.                                               |
| **LoRA Fine-Tuning**         | LoRA fine-tuning of custom or HuggingFace models using any dataset. Includes flexible hyperparameter tuning.                            |
| **Health Check**             | Comprehensive evaluation of GPU performance to ensure optimal hardware readiness before initiating any intensive computational workload.|
| **CPU Inference**            | Leverage Ollama to test CPU-based inference with models like Mistral, Gemma, and more.                                                  |

## Support & Contact

If you have any questions, issues, or feedback, contact [vishnu.kammari@oracle.com](mailto:vishnu.kammari@oracle.com) or [grant.neuman@oracle.com](mailto:grant.neuman@oracle.com).
