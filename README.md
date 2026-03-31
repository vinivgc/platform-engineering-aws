# Platform Engineering Project (AWS + Terraform + EKS)

## Overview

This project demonstrates a **platform engineering approach** to deploying applications on AWS using:

* Terraform (Infrastructure as Code)
* Amazon EKS (Kubernetes)
* Docker + ECR (Containerization)
* GitHub Actions (CI/CD)
* Helm (Kubernetes deployment abstraction)

---

## 🚀 Architecture

* Infrastructure is provisioned using Terraform
* Applications are containerized and pushed to ECR
* Deployments are standardized using Helm
* CI/CD automates build and deployment
* Kubernetes runs the application on EKS

---


## ⚙️ Setup

### Terraform Backend & Bootstrap

This project uses a **remote Terraform backend (S3 + DynamoDB)** for state management and locking.

Because Terraform cannot use a backend that does not yet exist, the backend infrastructure was **bootstrapped in an initial one-time step**:

1. Terraform was first run using **local state**
2. The S3 bucket and DynamoDB lock table were created
3. The Terraform state was then **migrated to the remote backend**
4. From that point on, all Terraform operations use the remote backend

> ℹ️ The backend resources are already created in this project, so the repository is currently configured to use the remote backend directly.

#### Running this project from scratch

If you were to run this project in a new AWS account, you would need to:

- temporarily switch the `bootstrap` stack to a **local backend**, or
- manually create the S3 bucket and DynamoDB table before running `terraform init`

---

## 🔁 End-to-End Flow

1. Developer pushes code
2. CI builds Docker image and pushes to ECR
3. CD deploys using Helm to EKS
4. Application is exposed via AWS LoadBalancer

---

## 🧱 Architecture Diagram

> Rendered using Mermaid (see `/docs/diagram.md`)

```
Developer → CI → ECR → CD → Helm → EKS → LoadBalancer → User
```

---

## ⚙️ Technologies Used

* AWS (EKS, ECR, IAM)
* Terraform
* Kubernetes
* Helm
* Docker
* GitHub Actions
* Python (Flask)

---

## 🧪 Sample Application

A simple Flask app:

* `/` → returns greeting
* `/health` → used for readiness/liveness probes

---

## 🛠️ Deployment Model

### CI (Build)

* Builds Docker image
* Tags image with commit SHA
* Pushes to ECR

### CD (Deploy)

* Triggered after CI success
* Deploys using Helm:

```
helm upgrade --install sample-app \
  k8s/charts/sample-app \
  --namespace dev \
  --set image.tag=sha-xxxxxxx
```

---

## 🧠 Platform Design Principles

### 1. Separation of Concerns

| Layer     | Responsibility        |
| --------- | --------------------- |
| Terraform | Infrastructure        |
| CI        | Build & push          |
| Helm      | Deployment definition |
| CD        | Deployment execution  |

---

### 2. Immutable Deployments

* Images tagged with commit SHA
* No reliance on `latest`

---

### 3. Abstraction over Kubernetes

Instead of exposing raw Kubernetes fields:

```yaml
nodeSelector
tolerations
affinity
```

The platform exposes:

```yaml
workloadProfile: general
exposure.type: public
```

---

### 4. Idempotent Deployments

```
helm upgrade --install
```

Ensures safe re-deployments.

---

### Terraform Stack Orchestration

This project keeps Terraform root stacks independent and composes them through shell scripts.

- Shared inputs such as `aws_region` and `project_name` are passed into each stack through generated `terraform.auto.tfvars.json` files
- The `platform` stack exports outputs such as `cluster_name` and `ecr_repository_arn`
- The orchestration script reads those outputs and passes them into the `platform-access/github-actions` stack

This keeps stack boundaries explicit while still allowing the repository to manage the full end-to-end workflow.

---

### GitHub Actions

#### GitHub Repository Variables

Shared platform configuration is stored as repository-level variables:

* AWS region
* IAM role ARN
* EKS cluster name
* ECR repository name
* Chart path and app path

These values originate from Terraform but are **intentionally decoupled** from runtime pipelines.

CI/CD pipelines do not depend on Terraform state.

#### GitHub Environments

Environment-specific configuration is handled via:

dev
prod

Each environment defines:

Kubernetes namespace

This enables:

Clear environment separation
Future support for approvals (e.g., production gating)
Environment-specific configuration without duplicating workflows

## 🌍 Environment

* Cluster: EKS
* Exposure: LoadBalancer

---

## 📈 Future Improvements

* Ingress/Gateway API instead of LoadBalancer
* Autoscaling (HPA)
* Observability (metrics/logging)
* Secrets management
* Add approval gates for production environment
* Introduce per-developer namespaces (preview environments)
* Sync Terraform outputs automatically to GitHub variables
* Add observability (logs/metrics)

---

## 🎯 Goal of the Project

To demonstrate:

* Real-world platform engineering practices
* Infrastructure + CI/CD integration
* Kubernetes abstraction for developers
* Clean, reproducible deployments

---

## 📬 Result

A fully working pipeline:

```
commit → build → push → deploy → running app on EKS
```