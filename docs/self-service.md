# Self-Service

## Overview

This document describes the developer-facing contract of the platform.

In this project, self-service does not mean a portal or a complex internal product. It means that a developer can consume the platform through a small, predictable set of inputs without needing to understand EKS internals, write raw Kubernetes manifests, or manually perform deployment steps every time.

The platform provides the paved road. The developer uses it.

## What the platform provides

From a developer point of view, the platform provides:

- a pre-provisioned Kubernetes runtime on AWS
- a container registry for published application images
- CI/CD workflows that build and deploy application versions
- a reusable Helm chart for workload deployment
- built-in support for ingress and autoscaling prerequisites
- environment-specific deployment paths for `dev` and `prod`

The main benefit is that the developer does not need to set up the infrastructure, delivery access, or core deployment mechanics for each application change.

## What the developer does

The developer workflow is intentionally small.

A developer is expected to:

- change application code in `apps/sample-app/`
- keep the application compatible with the platform contract
- rely on CI to validate and publish the application image
- rely on CD to deploy the image through Helm
- use the supported configuration inputs rather than writing raw deployment manifests
- promote a known immutable image to `prod` when needed

The goal is that application work stays focused on the application, while the platform handles the surrounding delivery and runtime concerns.

## Developer contract

### Application runtime contract

The application must be able to run in a container and listen on the configured runtime port.

In the current sample project, that means:

- the application listens on port `5000`
- the container starts successfully under Kubernetes
- the runtime can receive configuration through environment variables

### Health endpoint contract

The platform expects the application to expose health endpoints suitable for Kubernetes probes.

In the current sample app, those are:

- `/livez`
- `/readyz`

These endpoints are used by the platform to support liveness, startup, and readiness behavior.

### Container contract

The application must be buildable into a Docker image by CI.

That means the repository must contain:

- a buildable application path
- a valid Dockerfile and build context
- application behavior that works correctly when run inside the container

### Configuration contract

The application is expected to receive configuration through environment variables supplied by the platform.

The current sample app supports configuration such as:

- environment name
- application message
- readiness delay
- whether a message is required for readiness
- whether the stress endpoint is enabled

This is an important part of the self-service model because it keeps configuration external to the container image.

## Supported deployment inputs

The platform does not expect the developer to edit raw Kubernetes manifests directly. Instead, it exposes a smaller set of deployment inputs through Helm values.

### Image version

The image version is selected by the deployment workflow through an immutable tag of the form:

`sha-<short-commit>`

Developers do not need to manage Kubernetes image updates by hand.

### Configuration values

Application configuration is provided through the chart values under `config`.

Examples include:

- `appEnv`
- `appMessage`
- `readinessDelaySeconds`
- `requireMessage`
- `enableStressEndpoint`

### Scaling inputs

Scaling is controlled through the `scaling` section.

The chart supports inputs such as:

- whether scaling is enabled
- minimum replicas
- maximum replicas
- target CPU utilization
- scaling profile

### Ingress inputs

Exposure is controlled through the `ingress` section.

The chart supports inputs such as:

- whether ingress is enabled
- host
- path
- visibility

### Availability inputs

Availability is controlled through the `availability` section.

This allows the platform to apply PodDisruptionBudget behavior through a simpler intent-based input rather than requiring every workload to define that logic directly.

## Platform-owned concerns

The platform owns concerns that should not need to be re-implemented by the developer for each application.

These include:

- cluster provisioning
- AWS identity and access for CI/CD
- ECR registry integration
- kubeconfig setup inside workflows
- Helm-based deployment execution
- ingress controller installation
- metrics server installation
- default probe wiring
- standard deployment patterns such as rollout-based updates

This is one of the core platform engineering ideas demonstrated by the project: repeated operational concerns should be handled centrally, not rebuilt per application.

## Current self-service flow

The current developer-facing flow is:

- change application code
- open a pull request to validate the build
- merge to `main`
- let CI build and publish the image
- let dev CD deploy automatically
- manually promote an immutable image tag to `prod` when desired

This creates a simple paved road:

- developers focus on app changes
- the platform handles artifact publication and deployment
- production remains an explicit promotion step

## Scope and limits

The current self-service model is intentionally limited.

It currently supports:

- one sample application
- one reusable deployment chart
- `dev` and `prod` deployment paths
- configuration-driven deployment behavior
- ingress, scaling, and availability settings through values

It does not yet provide:

- a self-service onboarding flow for many teams
- per-developer preview environments
- secrets self-service
- policy-driven multi-tenant isolation
- application templates or golden paths for many workload types

Those are valid future extensions, but they are outside the scope of the current project.

## Summary

In this repository, self-service means that the platform reduces the number of things a developer needs to know in order to get an application deployed.

The developer does not need to manage cluster provisioning, AWS authentication, Helm execution, ingress controller installation, or raw Kubernetes deployment design. The platform handles those concerns and exposes a smaller, cleaner deployment contract through CI/CD and Helm values.