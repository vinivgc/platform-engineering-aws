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

## 🌍 Environment

* Namespace: `dev`
* Cluster: EKS
* Exposure: LoadBalancer

---

## 📈 Future Improvements

* Multi-environment support (dev/prod)
* Ingress (ALB) instead of LoadBalancer
* Autoscaling (HPA)
* Observability (metrics/logging)
* Secrets management

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