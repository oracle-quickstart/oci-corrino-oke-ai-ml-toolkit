# OCI AI Blueprints

> **Note**: We are currently rebranding from _Corrino_ to _OCI AI Blueprints_. The documentation may still contain references to Corrino in some areas. We appreciate your patience as we make this transition.

---

## Getting Started

Looking to install and use OCI AI Blueprints right away? **[Click here](./GETTING_STARTED_README.md) for our step-by-step guide**, which covers:

- Setting up IAM policies
- Creating an OKE cluster
- Installing OCI AI Blueprints
- Deploying and monitoring a sample blueprint
- Undeploying and cleaning up resources

We recommend following the Getting Started guide if this is your first time.

---

## Introduction

**OCI AI Blueprints** is a streamlined, no-code solution for deploying and managing Generative AI workloads on Oracle Cloud Infrastructure (OCI). By providing opinionated hardware recommendations, pre-packaged software stacks, and out-of-the-box observability tooling, OCI AI Blueprints helps you get your AI applications running quickly and efficiently—without wrestling with the complexities of infrastructure decisions, software compatibility, and MLOps best practices.

---

## Why Use OCI AI Blueprints?

Enterprises face three main challenges when running GenAI workloads on OCI:

1. **Hardware Decisions**  
   Choosing the right GPUs, networking, and storage configurations can be a painful, time-consuming process for data scientists and ML engineers.

2. **Software Stack Complexity**  
   Selecting and maintaining frameworks (e.g., PyTorch, TensorFlow), drivers (e.g., CUDA), and libraries can be difficult and error-prone. Ensuring ongoing compatibility can stall project timelines.

3. **Observability & MLOps**  
   Standing up a robust MLOps stack—monitoring, auto-scaling, experiment tracking—often involves Kubernetes expertise and custom tooling that can be tedious to maintain.

### How OCI AI Blueprints Solves These Challenges

1. **Validated Hardware Recommendations**  
   Deploy your GenAI workloads with confidence using pre-packaged blueprints tested on recommended OCI GPU, CPU, and networking configurations. This saves you from time-consuming performance benchmarking and guesswork.

2. **Opinionated, Pre-Packaged Software Stacks**  
   Each blueprint includes the necessary frameworks, libraries, and model configurations for a specific AI use case (e.g., RAG, fine-tuning, inference). Power users can further customize or swap out components as needed.

3. **Built-In Observability and Auto-Scaling**  
   By automating MLOps tasks—monitoring, logging, and scaling—OCI AI Blueprints simplifies infrastructure management. Tools like Prometheus, Grafana, MLFlow, and KEDA are automatically installed, giving you a production-grade environment with minimal effort.

---

## What Are Blueprints?

Blueprints go beyond basic Terraform templates. Each blueprint:

- Offers validated hardware suggestions (e.g., optimal shapes, CPU/GPU configurations).
- Includes end-to-end application stacks customized for different GenAI use cases.
- Comes with monitoring, logging, and auto-scaling configured out of the box.

After you install OCI AI Blueprints in your tenancy, you can deploy these pre-built blueprints (and more) quickly and reliably:

| Blueprint                    | Description                                                                                                                          |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| **LLM Inference**            | Deploy single-node inference for Llama 2/3/3.1 7B/8B models using NVIDIA GPU shapes and the vLLM inference engine with auto-scaling. |
| **Fine-Tuning Benchmarking** | Run MLCommons Llama2 quantized 70B LoRA finetuning on A100 for performance benchmarking.                                             |
| **LoRA Fine-Tuning**         | LoRA fine-tuning of custom or HuggingFace models using any dataset. Includes flexible hyperparameter tuning.                         |

---

## Blueprint Configuration

When deploying blueprints, you can customize:

- **LLM Model**
- **GPU Shape**
- **GPU Node Count**
- **Auto-Scaling Settings** (min/max replicas, application metrics such as inference latency)
- **Fine-Tuning Hyperparameters** (learning rate, epochs, etc.)
- And more (see [documentation](docs/api_documentation/README.md) for full details)

Sample configurations can be found [here](docs/sample_blueprints/README.md).

---

## Repository Contents

This repository provides comprehensive Terraform scripts that provision and configure:

1. An ATP database instance
2. Grafana & Prometheus for monitoring
3. MLFlow for experiment tracking
4. KEDA for dynamic auto-scaling
5. The OCI AI Blueprints front-end and back-end in an OKE cluster of your choice

Once installed, you can:

- Access the **OCI AI Blueprints Portal** and **API**.
- Deploy or undeploy blueprints for inference, training, and more.
- Deploy custom container images for your AI/ML workloads by simply pointing to the image URL.

---

## Additional Resources

- **OCI AI Blueprints API Documentation**: [API Docs](docs/api_documentation/README.md)
- **Sample Blueprints**: [Explore Here](docs/sample_blueprints/README.md)
- **Known Issues & Solutions**: [Ongoing List](docs/known_issues/README.md)

---

## Features

| Feature                        | Description                                                                                                                             | Instructions                                       |
| ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| **Customize Blueprints**       | Tailor existing OCI AI Blueprints to suit your exact AI workload needs—everything from hyperparameters to node counts and hardware.     | [Read More](docs/custom_blueprints/README.md)      |
| **Updating OCI AI Blueprints** | Keep your OCI AI Blueprints environment current with the latest control plane and portal updates.                                       | [Read More](docs/installing_new_updates/README.md) |
| **Shared Node Pool**           | Use longer-lived resources (e.g., bare metal nodes) across multiple blueprints or to persist resources after a blueprint is undeployed. | [Read More](docs/shared_node_pools/README.md)      |
| **File Storage Service**       | Store and supply model weights using OCI File Storage Service for blueprint deployments.                                                | [Read More](docs/fss/README.md)                    |
| **Auto-Scaling**               | Automatically adjust resource usage based on infrastructure or application-level metrics to optimize performance and costs.             | [Read More](docs/auto_scaling/README.md)           |

---

## Ways to Access OCI AI Blueprints

For details on accessing the Portal, API, and other endpoints, [click here](docs/api_documentation/accessing_oci_ai_blueprints/README.md).

---

## IAM Policies

See the [IAM Policies](docs/iam_policies/README.md) section for information on setting up and managing policies for OCI AI Blueprints.

---

## Frequently Asked Questions (FAQ)

**Q: What is the safest way to test OCI AI Blueprints in my tenancy?**  
A: Create a separate compartment and OKE cluster, then deploy OCI AI Blueprints there. This isolates any potential impacts.

**Q: Which containers and resources get deployed in my tenancy?**  
A:

1. OCI AI Blueprints front-end and back-end containers
2. Grafana & Prometheus (monitoring)
3. MLFlow (experiment tracking)
4. KEDA (application-based auto-scaling)

**Q: How can I run inference benchmarking?**  
A: Deploy a vLLM blueprint, then use a tool like LLMPerf to run benchmarking against your inference endpoint. Contact us for more details.

**Q: Where can I see the full list of blueprints?**  
A: All available blueprints are listed [here](docs/sample_blueprints/README.md). If you need something custom, please let us know.

**Q: How do I check logs for troubleshooting?**  
A: Use `kubectl` to inspect pod logs in your OKE cluster.

**Q: Does OCI AI Blueprints support auto-scaling?**  
A: Yes, we leverage KEDA for application-driven auto-scaling. See [documentation](docs/auto_scaling/README.md).

**Q: Which GPUs are compatible?**  
A: Any NVIDIA GPUs available in your OCI region (A10, A100, H100, etc.).

**Q: Can I deploy to an existing OKE cluster?**  
A: Yes, though testing on clusters running other workloads is ongoing. We recommend a clean cluster for best stability.

**Q: How do I run multiple blueprints on the same node?**  
A: Enable shared node pools. [Read more here](docs/shared_node_pools/README.md).

---

## Support & Contact

If you have any questions, issues, or feedback:

- Contact [vishnu.kammari@oracle.com](mailto:vishnu.kammari@oracle.com) or [grant.neuman@oracle.com](mailto:grant.neuman@oracle.com).

We look forward to helping you streamline your GenAI workloads on OCI!
