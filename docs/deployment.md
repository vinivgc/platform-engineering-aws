# Deployment

## Overview

This document explains how software moves from source code to running workloads in `dev` and `prod`.

The project uses a deliberately simple delivery model:

- CI builds the application image
- CI pushes the image to ECR on merges to `main`
- a successful CI run on `main` triggers automatic deployment to `dev`
- production deployment is a manual promotion of an existing immutable image tag

This keeps the delivery flow easy to reason about while still demonstrating a realistic separation between build and deployment.

## Deployment model

The deployment model follows a basic artifact promotion pattern. This document focuses on workflow behavior and environment promotion, while `docs/architecture.md` explains why the system is structured this way.

A code change to the sample application results in:

- a Docker image build
- an immutable image tag of the form `sha-<short-commit>`
- a pushed image in Amazon ECR when the change reaches `main`
- automatic deployment of that image to `dev`
- optional manual deployment of that same image to `prod`

The key principle is that production does not rebuild from source. It reuses an already-built artifact.

## CI workflow

### Trigger

The CI workflow lives in `.github/workflows/ci.yml`.

It runs on:

- pushes to `main`
- pull requests targeting `main`

It is scoped to changes in:

- `apps/sample-app/**`
- `.github/workflows/ci.yml`

This keeps the workflow focused on application delivery changes rather than running for unrelated repository edits.

### Responsibilities

The CI workflow is responsible for:

- checking out the repository
- setting an immutable image tag based on the commit SHA
- building the Docker image
- authenticating to AWS through GitHub OIDC on push events
- logging in to Amazon ECR on push events
- tagging the image for ECR
- pushing the immutable image tag on push events
- tagging and pushing `latest` on pushes to `main`

On pull requests, CI validates that the image can be built successfully but does not publish anything to ECR.

### Outputs

The main output of CI is a container image in ECR tagged like:

`sha-<short-commit>`

For example:

`sha-d93529a`

This image tag becomes the deployable artifact used by CD.

## Dev deployment workflow

### Trigger

The dev workflow lives in `.github/workflows/cd-dev.yml`.

It runs on `workflow_run`, meaning it is triggered by completion of the CI workflow. It only proceeds when:

- the CI workflow completed successfully
- the triggering event was a push
- the branch was `main`

This means dev deployment only happens for successful `main` builds.

### Responsibilities

The dev workflow is responsible for:

- checking out the repository at the exact commit CI built
- deriving the same immutable image tag from the commit SHA
- assuming the dev AWS deployment role through GitHub OIDC
- updating kubeconfig for the EKS cluster
- installing Helm
- running `helm upgrade --install`
- applying the `dev` values file
- overriding the image tag dynamically
- verifying rollout with `kubectl rollout status`

The workflow also lists pods and services after deployment as a basic verification step.

### Deployment target

The dev workflow targets:

- the shared EKS cluster
- the namespace configured through GitHub variables and the `dev` environment
- the values file `k8s/values/sample-app/dev.yaml`

This environment is intended to be the automatic landing zone for successful `main` changes.

## Prod deployment workflow

### Trigger

The prod workflow lives in `.github/workflows/cd-prod.yml`.

It runs manually through `workflow_dispatch` and requires an input:

- `image_tag`

This means production deployment is an explicit promotion step rather than an automatic side effect of merging to `main`.

### Responsibilities

The prod workflow is responsible for:

- checking out the repository
- assuming the prod AWS deployment role through GitHub OIDC
- updating kubeconfig for the EKS cluster
- installing Helm
- running `helm upgrade --install`
- applying the `prod` values file
- deploying the exact image tag provided as input
- verifying rollout with `kubectl rollout status`

### Deployment target

The prod workflow targets:

- the shared EKS cluster
- the namespace configured through GitHub variables and the `prod` environment
- the values file `k8s/values/sample-app/prod.yaml`

This creates an explicit promotion boundary between `dev` and `prod`.

## Artifact and image tag model

The project uses immutable image tags derived from the commit SHA:

`sha-<short-commit>`

This model is important because it provides:

- traceability from deployment back to source code
- consistent artifacts across environments
- easier reasoning about promotions
- a safer basis for rollback

The `latest` tag is also pushed on `main`, but it is only a convenience tag. It is not the source of truth for production deployment.

The source of truth for deployment is the immutable SHA-based image tag.

## Environment and GitHub configuration

### Repository variables

The workflows use repository variables for shared configuration such as:

- AWS region
- ECR repository name
- EKS cluster name
- chart path
- application path
- release name
- environment-specific role ARNs

This keeps shared deployment configuration outside the workflow files themselves.

### GitHub Environments

The workflows use GitHub Environments for `dev` and `prod`.

These environments serve as deployment boundaries and create a natural place for future controls such as approvals or environment-specific protections.

### AWS roles used by workflows

The workflows assume AWS roles through GitHub OIDC.

The model is separated by responsibility:

- CI assumes an ECR push role
- dev CD assumes a dev EKS deployment role
- prod CD assumes a prod EKS deployment role

This separation keeps the access model easier to review and closer to least privilege than using a single broad delivery role.

## Helm deployment behavior

Both CD workflows deploy with Helm using the chart in:

`k8s/charts/sample-app/`

Each environment uses a different values file:

- `k8s/values/sample-app/dev.yaml`
- `k8s/values/sample-app/prod.yaml`

The workflows override the image tag at deploy time rather than relying on the default tag in the chart values.

This allows the chart to remain reusable while the workflows remain responsible for selecting the exact artifact version to run.

## Deployment verification

A deployment is considered successful when:

- the GitHub workflow completes successfully
- Helm applies the release without error
- `kubectl rollout status` succeeds
- the deployment becomes ready in the target namespace

The current workflows also print pods and services after rollout, which helps with quick verification during early project development.

In practice, a reviewer can validate deployment success by checking:

- the CI run for image publication
- the CD run for Helm deployment
- the resulting pods and services in the cluster
- ingress behavior when enabled

## Common failure points

Common delivery failure points in this project include:

- GitHub OIDC trust policy misconfiguration
- incorrect AWS role ARN in repository variables
- wrong EKS cluster name or AWS region
- missing or incorrect ECR repository name
- image tag not present in ECR
- namespace mismatch between workflow and cluster state
- failed readiness due to application configuration
- ingress not behaving as expected because of ALB controller or ingress settings

These are useful to understand because they reflect the real boundaries between CI, AWS access, Helm deployment, and Kubernetes runtime behavior.

## Current limitations

The deployment model is intentionally simple.

Current limitations include:

- only one sample application is wired into the delivery flow
- no approval gate is implemented yet for production
- no automatic verification beyond rollout and basic resource listing
- no progressive delivery strategy such as canary or blue/green
- no GitOps-style reconciliation model

These are reasonable limitations for the current scope of the project and can be expanded later if they support the learning goals.

## Summary

The deployment flow of this repository is designed to be simple, explicit, and traceable.

CI builds and publishes an immutable image. Dev receives successful `main` builds automatically. Prod receives a manually selected immutable tag. This keeps the artifact flow easy to understand while still demonstrating a realistic separation between build, deployment, and environment promotion.