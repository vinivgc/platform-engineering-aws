# Architecture

## Overview

This project is structured as a small but realistic platform engineering system on AWS.

The design separates long-lived infrastructure, CI/CD access, cluster add-ons, application delivery, and developer-facing deployment configuration into distinct layers. The goal is to make the platform easier to reason about, easier to evolve, and easier to explain in interviews.

Rather than trying to simulate a full enterprise internal platform, the architecture focuses on a smaller set of patterns that are common in real teams and useful for demonstrating platform engineering judgment.

## Design goals

The architecture is designed around a few core goals:

- create a reusable Kubernetes-based runtime on AWS
- separate infrastructure provisioning from delivery workflows
- avoid long-lived cloud credentials in GitHub
- provide a simple but credible promotion path from `dev` to `prod`
- standardize application deployment through Helm instead of raw manifests
- keep the project intentionally small and understandable

These goals shape the main boundaries in the repository.

## Platform layers

### Infrastructure layer

The infrastructure layer creates the long-lived AWS foundation that workloads run on.

It includes:

- VPC and subnet networking
- EKS cluster and worker node capacity
- ECR repository for container images

This layer is mainly represented by:

- `terraform/platform/`
- `terraform/modules/networking/`
- `terraform/modules/eks-cluster/`
- `terraform/modules/ecr/`

Its responsibility is to provision the platform foundation, not to deploy application versions.

### Access layer

The access layer enables GitHub Actions to authenticate to AWS securely and to perform only the tasks needed for CI/CD.

It includes:

- GitHub OIDC provider
- IAM role for CI to push images to ECR
- IAM roles for CD to deploy to EKS
- environment-specific deployment access for `dev` and `prod`

This layer is mainly represented by:

- `terraform/platform-access/github-actions/`
- `terraform/modules/github-oidc-provider/`
- `terraform/modules/github-ecr-access/`
- `terraform/modules/github-eks-access/`

Its responsibility is to model delivery access as platform infrastructure, while keeping identity concerns separate from the cluster and workloads themselves.

### Add-ons layer

The add-ons layer installs cluster services that workloads depend on at runtime.

It currently includes:

- AWS Load Balancer Controller
- Metrics Server

This layer is mainly represented by:

- `terraform/platform-addons/`
- `terraform/modules/alb-controller/`
- `terraform/modules/metrics-server/`

Its responsibility is to provide shared cluster capabilities without mixing those concerns into base EKS provisioning.

### Delivery layer

The delivery layer defines how code becomes a deployable artifact and how that artifact reaches runtime environments.

It is mainly represented by:

- `.github/workflows/ci.yml`
- `.github/workflows/cd-dev.yml`
- `.github/workflows/cd-prod.yml`

Its responsibility is to build, publish, and promote application versions without embedding delivery logic into Terraform.

### Application deployment layer

The application deployment layer defines how workloads are described and standardized on the platform.

It is mainly represented by:

- `k8s/charts/sample-app/`
- `k8s/values/sample-app/`

Its responsibility is to provide a Helm-based deployment contract that captures platform concerns such as probes, scaling, ingress, availability, and security defaults.

### Application layer

The application layer is the sample workload used to exercise the platform.

It is mainly represented by:

- `apps/sample-app/`

Its responsibility is to demonstrate how an application consumes the platform rather than how the platform itself is provisioned.

## Terraform stack boundaries

### Bootstrap stack

`terraform/bootstrap/` handles the Terraform backend bootstrap.

Its job is to create the S3 bucket and DynamoDB table used for remote state and locking. This stack exists separately because Terraform cannot use a remote backend until those resources already exist.

### Platform stack

`terraform/platform/` provisions the main AWS platform foundation.

It composes modules for networking, EKS, and ECR. This is the long-lived base platform that application delivery depends on.

### Platform access stack

`terraform/platform-access/github-actions/` provisions GitHub Actions access to AWS.

It manages the GitHub OIDC provider and the IAM roles used by CI and CD. Keeping this stack separate makes the access model easier to review and avoids mixing delivery identity with core infrastructure.

### Platform add-ons stack

`terraform/platform-addons/` provisions shared cluster services.

It currently installs AWS Load Balancer Controller and Metrics Server. These are runtime capabilities that support workload deployment, but they are not part of the base network or cluster definition itself.

## Runtime architecture

The sample application runs in EKS and is deployed through Helm.

At runtime, the platform currently supports:

- Deployment for running pods
- Service for in-cluster connectivity
- Ingress for external exposure
- HorizontalPodAutoscaler when scaling is enabled
- PodDisruptionBudget through availability settings
- ConfigMap-based application configuration

The sample app exposes health and configuration endpoints that allow the platform to exercise several runtime concerns:

- liveness and startup behavior
- readiness behavior
- environment-driven configuration
- scaling experiments when the stress endpoint is enabled

Metrics Server supports autoscaling by making resource metrics available to the cluster. AWS Load Balancer Controller supports ingress-based exposure by reconciling Kubernetes Ingress resources into AWS load balancer infrastructure.

## Delivery architecture at a high level

Delivery is intentionally separated into build and deploy stages.

At a high level:

- CI builds the application image
- CI pushes the image to ECR on `main`
- dev CD automatically deploys the successful `main` build
- prod CD manually promotes a specific immutable image tag

This creates a simple artifact promotion model:

- build once
- deploy automatically to `dev`
- promote the same artifact manually to `prod`

The detailed operational behavior of those workflows is documented in `docs/deployment.md`.

## Repository structure as architecture

The top-level repository layout reflects platform boundaries, not just tool categories.

    .github/workflows/                 Delivery logic
    apps/sample-app/                   Workload code
    k8s/charts/sample-app/             Deployment contract
    k8s/values/sample-app/             Environment-specific deployment intent
    scripts/                           Operational orchestration between stacks
    terraform/bootstrap/               Backend bootstrap
    terraform/platform/                Core infrastructure
    terraform/platform-access/         Delivery access and IAM
    terraform/platform-addons/         Shared cluster capabilities
    terraform/modules/                 Reusable infrastructure building blocks
    docs/                              Documentation

This matters because the structure itself communicates design intent. It shows that infrastructure, access, add-ons, and workload delivery are related but distinct concerns.

## Key architectural choices

### Why EKS

EKS was chosen because it provides a managed Kubernetes control plane while still exposing the operational concepts that matter for platform engineering.

It is a good fit for this project because it lets the repository demonstrate:

- Kubernetes as a shared runtime platform
- AWS-native identity and networking integration
- realistic workload deployment patterns

### Why Helm

Helm was chosen because the goal is not just to deploy one sample app, but to demonstrate how a platform can provide a standardized application deployment contract.

In this project, Helm is the layer that turns platform defaults and reusable patterns into a developer-facing interface.

### Why GitHub OIDC

GitHub OIDC was chosen to avoid storing long-lived AWS credentials in GitHub.

This reflects a modern CI/CD security model in which workflows assume AWS roles dynamically. It is a better fit than static access keys for a portfolio project that aims to reflect current practice.

### Why split Terraform stacks

The Terraform stacks are split because different categories of platform work have different responsibilities and lifecycles.

Separating bootstrap, core platform, access, and add-ons improves:

- clarity
- change isolation
- explainability
- maintainability

It also avoids the common anti-pattern of turning one Terraform root module into a catch-all for every concern.

### Why ingress through AWS Load Balancer Controller

Ingress through AWS Load Balancer Controller was chosen because it is more representative of a platform model than exposing each application directly through its own `Service` of type `LoadBalancer`.

It lets the project express exposure intent through ingress configuration while delegating the implementation details to a shared cluster capability.

## Architectural non-goals

This architecture is intentionally scoped and does not try to cover every capability of a mature internal platform.

Deliberately out of scope for now:

- secrets management platform integration
- full observability stack
- GitOps-based deployment model
- advanced policy enforcement
- multi-tenant namespace isolation
- preview environments
- progressive delivery strategies
- service mesh

These are all valid future directions, but they are not required to demonstrate the core architectural choices this project is meant to show.

## Summary

The architecture of this repository is centered on a simple idea:

separate the major platform responsibilities clearly enough that the whole system remains understandable.

That is why the project uses distinct layers for infrastructure, access, add-ons, delivery, deployment abstraction, and workload code. The result is a portfolio project that is intentionally smaller than a full production platform, but still structured in a way that reflects real platform engineering thinking.