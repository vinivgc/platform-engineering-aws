# Self-Service Contract

## What the Platform Provides

The platform provides:

* AWS infrastructure provisioned with Terraform
* An EKS cluster to run workloads
* An ECR repository for container images
* CI to build and publish images
* Helm-based deployment templates
* CD workflows to deploy to Kubernetes

---

## What the Developer Does

The developer workflow is intentionally simple:

1. Change application code in:

```text
apps/sample-app/
```

2. Ensure the application:

* listens on the expected port
* exposes a health endpoint

3. Open a pull request

4. Merge to `main`

After merge:

* CI builds a new immutable image
* CD deploys that image automatically to `dev`

If production deployment is needed:

* run the manual production deployment workflow
* provide the desired image tag

---

## What the Developer Must Provide

The application must follow a small contract.

### Application requirements

The application must:

* run in a container
* listen on the configured application port
* expose a health endpoint for Kubernetes probes

For the current sample app, that means:

* port: `5000`
* health endpoint: `/health`

---

## What the Developer Does Not Need To Do

Developers do not need to:

* write Kubernetes Deployment YAML
* write Kubernetes Service YAML
* run Helm manually
* run `kubectl`
* manage namespaces
* interact with AWS directly
* understand node selectors, tolerations, or affinity rules

Those concerns are platform-owned.

---

## Deployment Model

### Development deployment

Development deployment is automatic.

Flow:

1. Code is merged to `main`
2. CI builds the image
3. CI pushes the image to ECR using an immutable tag:

   ```text
   sha-<commit>
   ```
4. CD deploys the image to the `dev` namespace using Helm

This gives fast feedback and continuous delivery to development.

---

### Production deployment

Production deployment is manual.

Flow:

1. A previously built image tag is selected
2. The manual production deployment workflow is triggered
3. The selected immutable image is deployed to `prod`

This gives a controlled promotion model:

* build once
* deploy to dev
* promote the same artifact to prod

---

## Supported Platform Inputs

The platform exposes a simplified deployment interface instead of raw Kubernetes configuration.

Examples of supported inputs include:

```yaml
deployment:
  replicas: 2

application:
  port: 5000
  healthPath: /health

exposure:
  type: public

workloadProfile: general

env:
  - name: APP_ENV
    value: dev
```

---

## Platform Abstractions

### Exposure type

Developers use:

```yaml
exposure:
  type: public
```

The platform translates that into the correct Kubernetes Service behavior.

Examples:

* `internal` → internal service
* `public` → externally reachable service

---

### Workload profile

Developers use:

```yaml
workloadProfile: general
```

The platform translates that into runtime defaults such as:

* CPU and memory requests
* CPU and memory limits
* future scheduling behavior if expanded later

Developers do not need to choose raw Kubernetes resource settings directly.

---

## Platform-Owned Concerns

The following are intentionally hidden behind the platform:

* Helm chart structure
* Kubernetes templates
* Service type implementation details
* rolling update strategy
* liveness and readiness probe wiring
* namespace handling
* cluster authentication
* EKS access configuration
* low-level scheduling controls

This is intentional. The platform should expose intent, not infrastructure complexity.

---

## Current Environment Model

The current project supports:

* automatic deployment to `dev`
* manual promotion to `prod`

Namespace is used as the environment boundary.

Examples:

* `dev`
* `prod`

---

## Artifact Model

Images are tagged with immutable commit-based tags:

```text
sha-<short-commit>
```

This means:

* every deployment is traceable
* the deployed version is explicit
* production can promote a known artifact
* rollback is easier

The `latest` tag may exist for convenience, but it is not used as the deployment source of truth.

---

## What This Demonstrates

This self-service model demonstrates the platform engineering idea that:

* developers focus on application code
* the platform standardizes delivery
* deployment is automated and repeatable
* Kubernetes complexity is abstracted away

---

## Current Scope

This project currently focuses on:

* one sample application
* one shared deployment model
* automatic deployment to `dev`
* manual promotion to `prod`

This is enough to demonstrate a credible platform-style workflow without overcomplicating the project.

---

## Future Extensions

Possible future improvements include:

* application-facing config outside the Kubernetes folder
* preview environments per branch
* gateway API/ingress-based routing
* autoscaling
* observability and monitoring

These are valid extensions, but they are not required for the current self-service contract to be meaningful.

---

## Summary

The self-service contract is:

* developers change application code
* CI builds immutable artifacts
* the platform deploys automatically to `dev`
* production uses controlled manual promotion
* deployment complexity stays owned by the platform

This keeps the developer experience simple while preserving standardization, traceability, and operational control.