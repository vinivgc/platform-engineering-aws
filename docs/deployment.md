# Deployment Flow Diagram

```
┌────────────────────┐
│   Developer Push   │
│  (apps/sample-app) │
└─────────┬──────────┘
          │
          ▼
┌──────────────────────────────┐
│        CI Pipeline           │
│ (GitHub Actions - CI)        │
│                              │
│ - Build Docker image         │
│ - Tag: sha-<commit>          │
│ - Push to ECR                │
└─────────┬────────────────────┘
          │
          ▼
┌──────────────────────────────┐
│        Amazon ECR            │
│                              │
│ repo:sha-xxxxxxx             │
└─────────┬────────────────────┘
          │
          ▼
┌──────────────────────────────┐
│        CD Pipeline           │
│ (GitHub Actions - CD)        │
│                              │
│ - Assume AWS role (OIDC)     │
│ - Connect to EKS             │
│ - Run Helm deploy            │
└─────────┬────────────────────┘
          │
          ▼
┌──────────────────────────────┐
│           Helm               │
│ (Deployment Template)        │
│                              │
│ - Deployment                │
│ - Service                   │
│ - Probes                    │
│ - Abstractions              │
└─────────┬────────────────────┘
          │
          ▼
┌──────────────────────────────┐
│        Kubernetes (EKS)      │
│                              │
│ Namespace: dev               │
│                              │
│ Pods (Flask app)             │
│ Service (LoadBalancer)       │
└─────────┬────────────────────┘
          │
          ▼
┌──────────────────────────────┐
│        AWS LoadBalancer      │
│                              │
│ Public Endpoint              │
└─────────┬────────────────────┘
          │
          ▼
┌──────────────────────────────┐
│          End User            │
│  http://<elb-url>            │
└──────────────────────────────┘
```

---

## Key Relationships

* CI produces immutable artifact → **ECR**
* CD deploys artifact → **EKS via Helm**
* Helm defines runtime → **Kubernetes resources**
* Service exposes app → **AWS LoadBalancer**

---

## Architecture Layers

```
Terraform → Infrastructure (EKS, IAM, ECR)

CI → Build & Push Image

Helm → Deployment Definition

CD → Deployment Execution
```

---

## Core Principle

> Same artifact (SHA image) flows through the system unchanged

Ensuring:

* consistency
* traceability
* reproducibility