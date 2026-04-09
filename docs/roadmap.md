# Roadmap

## Overview

This document captures the most useful next steps for the project and the areas that are intentionally deferred.

The goal of the roadmap is not to maximize feature count. It is to identify improvements that would deepen the platform engineering value of the repository while keeping it understandable and maintainable.

## Current state

The project currently includes:

- Terraform-managed AWS platform provisioning
- EKS as the Kubernetes runtime
- ECR as the image registry
- GitHub OIDC-based AWS authentication for CI/CD
- separate CI and CD workflows
- automatic deployment to `dev`
- manual promotion to `prod`
- a reusable Helm chart with platform-style abstractions
- AWS Load Balancer Controller and Metrics Server as cluster add-ons
- a sample application with health and configuration endpoints

This is already enough to demonstrate a credible end-to-end platform workflow.

## Next platform capabilities

After documentation and polish, the next meaningful platform capabilities to consider are:

- secrets management integration
- basic observability improvements
- stronger production promotion controls
- support for additional sample workloads or workload types
- a clearer multi-developer environment strategy

These would add depth to the platform story while still fitting the current project shape.

## Deliberately deferred areas

The following areas are intentionally deferred for now:

- GitOps as the primary deployment model
- service mesh
- advanced progressive delivery patterns
- full multi-tenant platform design
- extensive policy frameworks
- a full internal developer portal experience

These are all valid topics, but they would expand the project significantly and risk making it harder to keep coherent and interview-friendly.

## Summary

The roadmap for this repository is intentionally conservative.

The priority is to keep the project sharp, current, and easy to explain. Improvements should strengthen the platform engineering story of the repository rather than simply add more tools or more moving parts.