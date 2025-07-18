# Sentiric Infrastructure

**Description:** This repository manages all infrastructure resources required for deploying and running the Sentiric platform, leveraging Infrastructure as Code (IaC) principles. It defines the cloud or on-premise environment where Sentiric microservices operate.

**Core Responsibilities:**
*   Defining and provisioning cloud (e.g., AWS, Azure, GCP) or on-premise infrastructure resources (VMs, networks, Kubernetes clusters, databases, storage).
*   Containing Kubernetes manifests, Helm charts, or Docker Compose files for production/staging environments.
*   Automating the deployment, scaling, and backup processes of the platform.

**Technologies:**
*   Terraform (for cloud infrastructure provisioning)
*   Kubernetes (YAML manifests, Helm Charts)
*   Ansible/Puppet/Chef (for configuration management, if needed)
*   Pulumi (as an alternative to Terraform, if using code-based IaC)

**Usage:**
This is **not a running application service**; it's the **automation for your underlying infrastructure**. It's used by DevOps/SRE teams to set up and manage the environments where other Sentiric services run.

**Local Development:**
1.  Clone this repository: `git clone https://github.com/sentiric/sentiric-infrastructure.git`
2.  Navigate into the directory: `cd sentiric-infrastructure`
3.  Review and modify IaC scripts.
4.  Apply infrastructure changes using `terraform apply`, `kubectl apply`, or `helm upgrade`.

**Deployment:**
Manages the deployment of all other Sentiric services. Its own deployment involves applying IaC scripts to the target environment.

**Contributing:**
We welcome contributions to infrastructure definitions! Please refer to the [Sentiric Governance](https://github.com/sentiric/sentiric-governance) repository for guidelines on infrastructure as code and deployment best practices.

**License:**
This project is licensed under the [License](LICENSE).
