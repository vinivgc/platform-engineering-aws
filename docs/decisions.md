# Decisions

## Repository and Terraform structure

### Separate bootstrap from platform stacks

**Decision:** Keep Terraform backend bootstrap in `terraform/bootstrap/` instead of combining it with the main platform stack.

**Reason:**  
The remote backend must exist before Terraform can use it. Treating backend creation as a separate concern keeps that bootstrap step explicit and avoids mixing one-time state infrastructure with the long-lived platform itself.

### Keep Terraform root stacks independent

**Decision:** Use separate Terraform root stacks for bootstrap, core platform, platform access, and platform add-ons.

**Reason:**  
These areas represent different responsibilities and change at different times. Keeping them independent improves clarity, reduces coupling, and makes the project easier to explain and evolve.

### Keep platform access separate from core platform infrastructure

**Decision:** Manage GitHub Actions OIDC and IAM access in `terraform/platform-access/github-actions/` rather than inside the core platform stack.

**Reason:**  
CI/CD access is delivery infrastructure, not cluster runtime infrastructure. Separating it keeps the identity model easier to review and prevents the core platform stack from becoming a catch-all.

### Keep cluster add-ons separate from core platform provisioning

**Decision:** Manage shared cluster services such as AWS Load Balancer Controller and Metrics Server in `terraform/platform-addons/`.

**Reason:**  
Cluster add-ons are runtime capabilities used by workloads, not part of the minimum network and cluster definition. This boundary keeps the EKS provisioning layer simpler and makes runtime dependencies more visible.

## Access and security model

### Use GitHub OIDC for AWS authentication

**Decision:** Authenticate GitHub Actions to AWS using GitHub OIDC and assumable IAM roles instead of static AWS credentials.

**Reason:**  
This avoids storing long-lived secrets in GitHub, uses temporary credentials, and reflects modern CI/CD security practice.

### Separate CI image-push access from CD cluster-deploy access

**Decision:** Use different AWS roles for image publishing and Kubernetes deployment.

**Reason:**  
CI and CD perform different actions and should not share the same level of access. Splitting the roles keeps permissions easier to reason about and closer to least privilege.

### Use environment-specific deployment access for dev and prod

**Decision:** Use separate EKS deployment access for `dev` and `prod`.

**Reason:**  
Even in a small project, environment separation is easier to explain and safer to evolve when deployment access is explicitly modeled per environment instead of shared through one broad role.

## Delivery model

### Separate CI from CD

**Decision:** Implement CI and CD as separate GitHub Actions workflows.

**Reason:**  
CI is responsible for creating artifacts. CD is responsible for deploying artifacts. Keeping those responsibilities separate improves clarity, creates a cleaner promotion model, and better reflects common delivery practice.

### Build once and promote the same artifact

**Decision:** Use immutable commit-based image tags and promote the same built image across environments.

**Reason:**  
This improves traceability and consistency. Production receives a known artifact instead of a rebuilt one, which makes the deployment model easier to trust and explain.

### Auto-deploy to dev and promote manually to prod

**Decision:** Deploy successful `main` builds automatically to `dev`, but require a manual trigger for `prod`.

**Reason:**  
This gives fast feedback in `dev` while preserving an explicit promotion step for production. It keeps the pipeline simple without making production deployment automatic by default.

## Kubernetes and deployment model

### Use Helm as the application deployment layer

**Decision:** Standardize workload deployment through a reusable Helm chart instead of relying on raw manifests.

**Reason:**  
The project is meant to demonstrate platform engineering, not just Kubernetes YAML authoring. Helm provides a clearer place to encode reusable deployment patterns and developer-facing abstractions.

### Use ingress-based exposure instead of coupling apps directly to load balancer services

**Decision:** Expose workloads through Kubernetes Ingress backed by AWS Load Balancer Controller.

**Reason:**  
This is closer to a platform model than exposing each application directly through its own `Service` of type `LoadBalancer`. It creates a cleaner shared exposure pattern and better reflects how platforms often centralize traffic entry.

### Expose platform abstractions instead of raw Kubernetes complexity

**Decision:** Provide platform-oriented inputs for workload behavior, scaling, ingress, availability, and security through Helm values.

**Reason:**  
A platform should reduce the amount of low-level Kubernetes knowledge needed for common deployments. This makes the developer contract simpler and highlights the platform’s role in standardization.

## Scope and simplicity

### Optimize for clarity over maximum abstraction

**Decision:** Prefer a clear, interview-friendly implementation over adding every possible abstraction or enterprise feature.

**Reason:**  
The goal of the project is to demonstrate sound judgment and clean structure. Too much abstraction would make the repository harder to review and maintain without improving its learning or portfolio value.

### Keep the project intentionally small but realistic

**Decision:** Limit the project to a single sample application, two environments, a simple promotion model, and a focused set of platform capabilities.

**Reason:**  
A smaller but coherent project is easier to keep current and easier to discuss in interviews. The scope is large enough to show platform thinking without turning the repository into an unfinished simulation of a much larger system.