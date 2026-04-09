# Platform Engineering Project (AWS + Terraform + EKS)

## Overview

This repository is a portfolio project built to demonstrate a practical **platform engineering approach** on AWS.

It combines:

- **Terraform** for infrastructure provisioning
- **Amazon EKS** for Kubernetes runtime
- **Amazon ECR** for container image storage
- **GitHub Actions** for CI/CD
- **Helm** for standardized application deployment

The project is intentionally scoped to be realistic enough for interviews and learning, while still small enough to understand, explain, and maintain.

## Why this project exists

I built this repository as part of my transition into platform engineering.

The goal is not only to show that I can use individual tools, but that I can structure them into a coherent platform with clear boundaries between infrastructure, access, cluster capabilities, delivery workflows, and developer-facing deployment abstractions.

This project is meant to serve three purposes:

- a hands-on learning project
- a portfolio project for interviews
- a reference repository for platform engineering concepts and tradeoffs

## What this project demonstrates

This project demonstrates:

- Terraform-managed AWS platform provisioning
- an EKS-based runtime environment
- an ECR-based container artifact flow
- GitHub OIDC-based AWS authentication for CI/CD
- separation between CI image publishing and CD cluster deployment access
- Helm as the application deployment contract
- automatic deployment to `dev`
- manual promotion to `prod`
- platform-style abstractions for scaling, availability, security, and ingress

## High-level solution summary

At a high level, the platform works like this:

- Terraform provisions the AWS foundation and supporting platform components
- GitHub Actions builds the sample application container image
- CI pushes the image to Amazon ECR
- CD deploys the image to Amazon EKS with Helm
- The application is exposed through Kubernetes Ingress using AWS Load Balancer Controller

The result is a small but complete path from source code to running workload, with clear separation between provisioning, delivery, and runtime concerns.

## Repository map

Key parts of the repository:

    .github/workflows/                 CI/CD workflows
    apps/sample-app/                   Sample application
    k8s/charts/sample-app/             Reusable Helm chart
    k8s/values/sample-app/             Environment-specific values
    scripts/                           Terraform orchestration scripts
    terraform/bootstrap/               Remote state bootstrap
    terraform/platform/                Core platform infrastructure
    terraform/platform-access/         GitHub Actions access and IAM
    terraform/platform-addons/         Cluster add-ons
    terraform/modules/                 Reusable Terraform modules
    docs/                              Supporting project documentation

## Documentation guide

Additional project documentation lives under `docs/`:

- `docs/architecture.md` — how the platform is structured and why
- `docs/deployment.md` — how software moves from source code to `dev` and `prod`
- `docs/self-service.md` — the developer-facing platform contract
- `docs/decisions.md` — key engineering decisions and rationale
- `docs/roadmap.md` — current priorities and intentionally deferred areas

The README is intentionally brief; the detailed design, delivery, and platform contract live in the documents under `docs/`.