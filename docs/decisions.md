# Decisions

## 2026-03-17

### Use one repo instead of multiple repos
Reason: faster delivery, easier to explain in interviews, less operational overhead for a portfolio project.

### Start with a single dev environment
Reason: speed matters more than enterprise-grade environment separation for MVP.

## 2026-03-18

### Separate bootstrap from environment stacks

**Decision:** Place Terraform bootstrap in `terraform/bootstrap/` instead of under `environments/`.

**Reason:**
Bootstrap resources (S3 state bucket, DynamoDB lock table) are shared foundational infrastructure and not tied to a specific environment like dev or prod. Separating them improves clarity and reflects real-world structure.

### Use a single bootstrap stack for all environments

**Decision:** Use one bootstrap stack for dev, stage, and prod.

**Reason:**
Backend resources are shared across environments, while state isolation is handled via different state keys. This avoids unnecessary duplication and keeps the setup simple and maintainable.

### Isolate Terraform state per environment

**Decision:** Use different state keys per environment (e.g., `dev/`, `stage/`, `prod/`).

**Reason:**
State isolation prevents environments from interfering with each other and reduces the risk of accidental changes or destruction across environments.

### Avoid dynamic backend configuration

**Decision:** Keep backend configuration explicit per environment instead of trying to parameterize it.

**Reason:**
Terraform backend configuration is initialized separately from normal variables. Making it dynamic increases complexity and can lead to misconfiguration or accidental state overlap.

### Use local state first, then migrate to remote backend

**Decision:** Run bootstrap initially with local state, then optionally migrate to remote state.

**Reason:**
Backend resources must exist before they can be used. This avoids circular dependencies and follows Terraform’s initialization model.

### Use default_tags in provider configuration

**Decision:** Apply tags globally via `default_tags` instead of per resource.

**Reason:**
Ensures consistent tagging across all resources and reflects platform engineering practices where governance is enforced automatically.

### Tag bootstrap resources without environment tag

**Decision:** Apply `Project`, `Owner`, and `ManagedBy` tags, but not `Environment` in bootstrap.

**Reason:**
Bootstrap resources are shared and not tied to a single environment. Environment tags are applied in environment-specific stacks.

### Parameterize project naming

**Decision:** Use `project_name` variable for naming resources.

**Reason:**
Improves consistency, reusability, and makes it easier to adapt the configuration for other projects or environments.

### Protect critical backend resources

**Decision:** Use `prevent_destroy` on S3 bucket and DynamoDB table.

**Reason:**
Accidental deletion of Terraform state or lock table can break infrastructure management. Protection is applied where the operational risk is highest.

### Do not over-engineer early (no modules yet)

**Decision:** Avoid creating Terraform modules at the start.

**Reason:**
Abstraction too early leads to poor module design. It is better to understand actual usage patterns first, then extract reusable components.

### Use a monorepo structure

**Decision:** Keep infrastructure, application, and CI/CD in a single repository.

**Reason:**
Simplifies development, improves visibility, and is sufficient for a portfolio project while still reflecting real-world setups in smaller teams.

### Keep initial scope to a single environment (dev)

**Decision:** Start with only a dev environment.

**Reason:**
Prioritizes speed and learning. Additional environments can be added later once the core platform is working.

## 2026-03-19

### Use two availability zones
**Decision:** Deploy networking across two availability zones.

**Reason:**  
Provides a more realistic and resilient EKS-ready setup while keeping the architecture simple.

### Use public and private subnets
**Decision:** Place ingress-facing components in public subnets and worker nodes in private subnets.

**Reason:**  
This reflects common AWS and EKS networking practices and improves security posture.

### Use a single NAT Gateway
**Decision:** Use one NAT Gateway instead of one per availability zone.

**Reason:**  
This reduces cost and complexity for a portfolio environment while still supporting private subnet outbound access.

### Prioritize deterministic infrastructure behavior

**Decision:** Favor predictable, order-dependent constructs over more abstract or dynamic patterns.

**Reason:**
Deterministic infrastructure reduces unexpected changes in Terraform plans and simplifies debugging, which is especially important in early-stage or learning environments.

### Prefer dynamic AZ selection over hardcoding

**Decision:** Select availability zones dynamically using the AWS data source instead of hardcoding AZ names.

**Reason:**
Availability zone names are account-specific in AWS. Dynamic selection improves portability and avoids issues when deploying the same configuration across different accounts or regions.

## 2026-03-21

### Use EKS as a managed control plane boundary
**Decision:** Treat the Kubernetes control plane as an AWS-managed service boundary rather than something to customize directly.

**Reason:**  
In EKS, low-level control plane concerns such as etcd topology, static pod management, and control plane component configuration are intentionally abstracted away. The platform design should therefore focus on cluster consumption, workload management, networking, access, and automation rather than self-managed control plane administration.

### Prefer node-based EKS over Fargate for the initial platform design
**Decision:** Start with EC2-backed managed node groups instead of EKS Fargate.

**Reason:**  
Node groups expose more of the infrastructure and Kubernetes operational model, including worker capacity, daemonset compatibility, scaling tradeoffs, and node placement. This makes the project stronger for learning and for interviews focused on Cloud, DevOps, or Platform Engineering roles.

### Separate Kubernetes workload scaling from infrastructure capacity scaling
**Decision:** Treat pod scaling and node scaling as separate concerns in the platform design.

**Reason:**  
Kubernetes workload scaling is handled through Kubernetes resources such as replica counts and Horizontal Pod Autoscaler, while infrastructure capacity is bounded by node group scaling settings. Keeping these concerns separate makes the platform easier to reason about and scale safely.

### Do not rely on Terraform for local operator access workflows
**Decision:** Keep kubeconfig refresh and local cluster access outside Terraform, using helper scripts instead.

**Reason:**  
Provisioning infrastructure and configuring a developer workstation are different concerns. This separation avoids mixing infrastructure state with local execution behavior and results in a cleaner operating model.

### Expect ephemeral environment recreation as part of cost control
**Decision:** Design the platform workflow to support frequent destroy-and-recreate cycles in the dev environment.

**Reason:**  
Because EKS, NAT Gateway, and worker nodes generate ongoing cost, regularly destroying the environment is a practical cost-control strategy for a portfolio project. This makes repeatable provisioning and reconnection workflows important design considerations.

### Use local helper scripts for cluster access
**Decision:** Use shell scripts to refresh kubeconfig after recreating the EKS cluster instead of embedding local commands in Terraform.

**Reason:**  
Updating kubeconfig is a local workstation concern, not infrastructure state. Keeping it outside Terraform preserves cleaner separation between provisioning and operator workflow.

## 2026-03-22

### Use Service type LoadBalancer as the first exposure method
**Decision:** Expose the first sample application with a Kubernetes Service of type `LoadBalancer`.

**Reason:**  
This is the simplest way to validate end-to-end integration between EKS, Kubernetes Services, AWS networking, and subnet tagging before introducing more advanced traffic management components.

### Defer ingress architecture until after basic platform validation
**Decision:** Do not start with Ingress or Gateway API for the first workload exposure.

**Reason:**  
Ingress and Gateway API require additional controllers, configuration, and debugging surface. For the initial platform milestone, the priority is proving that the cluster can run and expose workloads successfully with the fewest moving parts.

### Clean up Kubernetes-created cloud resources before destroying infrastructure
**Decision:** Delete Kubernetes Services and workloads before running `terraform destroy`.

**Reason:**  
Resources created indirectly by Kubernetes, such as AWS load balancers, are not tracked in Terraform state. Cleaning them up through Kubernetes first reduces the risk of orphaned cloud resources and unnecessary cost (added to the script).

### Support frequent cluster recreation with local helper scripts
**Decision:** Use local scripts to streamline reconnecting to recreated clusters.

**Reason:**  
Because the dev environment will be destroyed and recreated regularly for cost control, cluster access steps such as refreshing kubeconfig should be easy and repeatable.

### Refresh kubeconfig after cluster recreation
**Decision:** Re-run `aws eks update-kubeconfig` after recreating the EKS cluster.

**Reason:**  
Even when the cluster name remains the same, the endpoint and certificate data may change after recreation. Refreshing kubeconfig ensures `kubectl` points to the current cluster.

## 2026-03-23

### Use GitHub OIDC for AWS authentication

**Decision:** Authenticate GitHub Actions to AWS using OIDC and an assumable IAM role instead of static access keys.

**Reason:**
This avoids storing long-lived AWS credentials in GitHub and uses temporary credentials, which is the recommended security model for CI/CD pipelines.

### Restrict GitHub Actions trust policy to repository and branch

**Decision:** Limit the IAM role trust relationship to the specific repository and 'main' branch.

**Reason:**
This enforces least privilege and ensures only authorized workflows from the intended repository and branch can assume the role.

### Manage CI/CD cloud access as infrastructure

**Decision:** Define the GitHub OIDC provider and IAM role using Terraform.

**Reason:**
These are AWS infrastructure components and should be managed as code for repeatability, auditability, and consistency.

### Separate CI/CD access from environment infrastructure

**Decision:** Place GitHub Actions IAM configuration in a dedicated Terraform stack ('platform-access/') instead of inside environment stacks.

**Reason:**
CI/CD identity is shared platform access infrastructure, not tied to a specific environment like dev or prod.

### Use remote state for all Terraform stacks

**Decision:** Configure remote state for platform-access Terraform stacks in addition to environment stacks

## 2026-03-24

### Define CI/CD scope for application deployment only
**Decision:** Limit Phase 5 to application deployment via GitHub Actions, excluding infrastructure provisioning.
**Reason:** Establishing a working deployment pipeline to EKS is the immediate goal. Infrastructure automation via CI/CD introduces additional complexity and is intentionally deferred to a later phase.

### Use OIDC for GitHub Actions authentication
**Decision:** Authenticate GitHub Actions to AWS using OIDC instead of static access keys.
**Reason:** OIDC provides short-lived credentials, improves security, and aligns with modern production practices by eliminating long-lived secrets.

### Restrict IAM role trust to repository and branch
**Decision:** Limit the IAM role trust policy to a specific GitHub repository and branch.
**Reason:** Prevents unauthorized role assumption and enforces least privilege at the identity level.

### Grant minimal AWS permissions to GitHub Actions role
**Decision:** Assign only `eks:DescribeCluster` permission to the GitHub Actions IAM role.
**Reason:** This is the minimum required for generating kubeconfig. Kubernetes-level access is handled separately via EKS access entries.

### Use EKS access entries for Kubernetes authorization
**Decision:** Manage Kubernetes API access using `aws_eks_access_entry` and `aws_eks_access_policy_association`.
**Reason:** This is the modern and recommended way to grant IAM identities access to EKS, replacing direct aws-auth ConfigMap management.

### Grant cluster-admin access for initial CI/CD setup
**Decision:** Assign `AmazonEKSClusterAdminPolicy` to the GitHub Actions role at cluster scope.
**Reason:** Broad access ensures reliability during initial setup and reduces friction. It will be restricted in a later hardening phase.

### Manage CI/CD access in a dedicated Terraform stack
**Decision:** Keep GitHub Actions IAM, OIDC provider, and EKS access configuration in the `platform-access/github-actions` stack.
**Reason:** CI/CD access is shared platform infrastructure and should remain separate from environment-specific resources.

### Pass EKS cluster name as variable between stacks
**Decision:** Provide the EKS cluster name to the `platform-access` stack via a variable.
**Reason:** Avoids early complexity with remote state wiring and keeps stacks loosely coupled. Can be refactored later.

### Structure Terraform state keys by stack path
**Decision:** Organize S3 backend keys to reflect repository structure (e.g. `platform-access/github-actions/terraform.tfstate`).
**Reason:** Improves clarity, scalability, and maintainability as more stacks are added.

### Use a single generic deployment workflow
**Decision:** Name the GitHub Actions workflow `deploy.yml`.
**Reason:** Keeps the workflow reusable and avoids tight coupling to a specific application.

### Store workflow in standard GitHub directory
**Decision:** Place the workflow in `.github/workflows/`.
**Reason:** This is the required and standard location for GitHub Actions workflows.

### Use ubuntu-latest for GitHub runner
**Decision:** Use `runs-on: ubuntu-latest`.
**Reason:** Standard practice with low maintenance overhead. Version pinning can be introduced later if needed.

### Limit GitHub Actions permissions
**Decision:** Set workflow permissions to `id-token: write` and `contents: read`.
**Reason:** Enables OIDC authentication while following least privilege principles.

### Store Kubernetes manifests with the application
**Decision:** Keep Kubernetes manifests in `apps/sample-app/`.
**Reason:** Keeps application code and deployment configuration together and avoids unnecessary structure early on.

### Keep CI/CD implementation simple for initial phase
**Decision:** Avoid introducing Helm, Kustomize, or multi-environment overlays at this stage.
**Reason:** Focus is on delivering a working pipeline quickly. Additional abstraction will be introduced when complexity increases.

### Defer infrastructure automation in CI/CD
**Decision:** Do not implement Terraform execution via GitHub Actions yet.
**Reason:** Separating concerns allows focusing on application delivery first. Infrastructure automation will be added in the next phase.

## 2026-03-25

### Separate CI (build) from CD (deployment)

**Decision:** Implement CI and CD as two separate GitHub Actions workflows instead of combining them into a single pipeline.

**Reason:**
CI and CD have different responsibilities. CI builds and publishes artifacts, while CD deploys them. Separating them improves clarity, aligns with professional practices, and allows independent control over build and deployment processes.

### Trigger CI on push to main and pull requests

**Decision:** Configure the CI workflow to run on pull requests targeting `main` and on pushes to `main`.

**Reason:**
Pull request runs validate that code builds correctly before merge, while push events to `main` produce the official deployable artifact. This ensures only approved code is published.

### Build images on PR, push images only from main

**Decision:** Build Docker images during pull request workflows but only push images to ECR on pushes to `main`.

**Reason:**
PR builds validate changes without polluting ECR with temporary artifacts. Only stable, reviewed code from `main` produces published images, keeping the registry clean and meaningful.

### Use commit SHA as the primary image tag

**Decision:** Tag Docker images using `sha-<short_commit_sha>`.

**Reason:**
Commit SHA tags provide full traceability between an image and the exact source code version. They are immutable and ideal for reproducible deployments.

### Use 'latest' tag only for main branch builds

**Decision:** Apply the `latest` tag only when building from the `main` branch.

**Reason:**
The `latest` tag is a moving pointer and should represent the most recent approved version. Restricting it to `main` prevents unstable or unreviewed code from being marked as the latest version.

### Use GitHub OIDC for AWS authentication

**Decision:** Authenticate GitHub Actions to AWS using OpenID Connect (OIDC) instead of static credentials.

**Reason:**
OIDC provides short-lived, secure credentials without storing secrets in GitHub. This is the modern and recommended approach for CI/CD authentication.

### Use a single ECR repository per application

**Decision:** Use one ECR repository per application (e.g., `sample-app`) instead of separate repositories per environment.

**Reason:**
Images should be built once and promoted across environments using tags. This avoids rebuilding the same artifact and aligns with best practices for artifact immutability.

### Build Docker images from application-specific directories

**Decision:** Use `apps/sample-app/` as the Docker build context for the CI pipeline.

**Reason:**
This maintains clear separation between application code and infrastructure code, improving repository organization and scalability.

### Keep CI focused on build and publish only

**Decision:** Ensure the CI workflow only builds and pushes Docker images, without provisioning infrastructure.

**Reason:**
Infrastructure provisioning belongs to Terraform. Keeping CI focused on application artifacts ensures clean separation of concerns and aligns with platform engineering principles.

### Use image tags as the contract between CI and CD

**Decision:** Use the image tag (e.g., `sha-<commit>`) in ECR as the interface between CI and CD.

**Reason:**
CI produces versioned images, and CD consumes them. This decouples build and deployment and allows precise, reproducible deployments.

### Avoid premature generalization of CI workflows

**Decision:** Implement an application-specific CI workflow (e.g., `ci-sample-app.yml`) instead of a generic multi-app pipeline.

**Reason:**
With only one application, explicit and simple workflows improve clarity. Generalization should only be introduced when multiple applications require reuse.

### Use PR workflow runs for build validation

**Decision:** Use pull request-triggered workflows to validate that the application builds successfully before merging.

**Reason:**
Ensures code quality and prevents broken builds from reaching the main branch, without publishing unnecessary artifacts.

### Treat 'latest' as a convenience, not a source of truth

**Decision:** Do not rely on the `latest` tag for deployment decisions.

**Reason:**
The `latest` tag is mutable and can change over time. Immutable SHA tags provide a reliable and reproducible deployment reference.

## 2026-03-27

### Use Helm as the Kubernetes deployment layer

**Decision:** Use Helm instead of raw Kubernetes manifests as the standardized deployment mechanism for the sample application.

**Reason:**
Helm provides templating, reuse, and parameterization, which makes the deployment layer easier to standardize and automate. This aligns better with a platform engineering approach than maintaining one-off YAML files.

### Replace raw test manifests with a reusable Helm chart

**Decision:** Replace the initial raw Kubernetes manifests used for EKS connectivity testing with a reusable Helm chart for the sample application.

**Reason:**
The original nginx deployment and service were useful only as a connectivity check. A Helm chart better represents a real deployment model and demonstrates how applications should be deployed consistently on the platform.

### Keep Terraform, CI, Helm, and CD as separate layers

**Decision:** Separate the project into distinct layers for infrastructure provisioning, image build, deployment definition, and deployment execution.

**Reason:**
Each layer has a different responsibility. Terraform provisions infrastructure, CI builds and pushes images, Helm defines how the application runs in Kubernetes, and CD performs the deployment. This separation of concerns makes the project easier to understand, maintain, and explain.

### Use Helm as a reusable deployment template, not as application-specific one-off YAML

**Decision:** Treat the Helm chart as a reusable deployment template for the application instead of a one-time deployment artifact.

**Reason:**
The goal of the deployment layer is to standardize how applications run on Kubernetes. A reusable template better demonstrates platform engineering principles than manually edited manifests.

### Use `helm upgrade --install` as the deployment command

**Decision:** Use `helm upgrade --install` as the standard deployment command for the application.

**Reason:**
This command is idempotent: it installs the release if it does not exist and upgrades it if it already exists. This makes deployments repeatable and suitable for automation in CD pipelines.

### Use a Kubernetes namespace as the environment boundary

**Decision:** Use the Kubernetes namespace as the environment boundary for deployments, starting with the `dev` namespace.

**Reason:**
Using a namespace to represent an environment is cleaner than naming the namespace after the application. It supports reuse of the same Helm chart across environments and aligns with common Kubernetes deployment practices.

### Remove namespace management from the Helm chart

**Decision:** Do not create namespaces from within the Helm chart and instead manage the target namespace via Helm CLI flags such as `--namespace` and `--create-namespace`.

**Reason:**
The target namespace is part of deployment context rather than application definition. Managing it outside the chart avoids conflicts and keeps the chart environment-agnostic.

### Deploy the sample application into the `dev` namespace

**Decision:** Deploy the sample application into the `dev` namespace rather than an application-named namespace such as `sample-app`.

**Reason:**
This supports the model where environments are represented by namespaces. It also creates a cleaner path for future multi-environment expansion.

### Use one reusable Helm chart per application

**Decision:** Keep a single Helm chart for the application rather than creating separate charts per environment.

**Reason:**
The deployment logic should be standardized and reused across environments. Environment differences should be expressed through values or deployment inputs, not duplicated charts.

### Use chart defaults for shared configuration and pipeline overrides for dynamic values

**Decision:** Keep shared defaults in `values.yaml` and override only dynamic values, such as the image tag, during deployment.

**Reason:**
Static defaults belong in the chart, while deployment-specific values should be injected by the pipeline. This keeps the deployment process clean and minimizes unnecessary CLI overrides.

### Use developer-friendly Helm values instead of exposing raw Kubernetes fields

**Decision:** Design the Helm chart to expose a small, developer-friendly interface instead of exposing low-level Kubernetes fields directly.

**Reason:**
Developers should not need to understand internal Kubernetes scheduling concepts such as affinity, tolerations, or node selectors. A platform should expose intent, not raw infrastructure primitives.

### Abstract service exposure behind a platform-friendly setting

**Decision:** Expose service accessibility through a simple `exposure.type` value such as `internal` or `public`.

**Reason:**
This hides raw Kubernetes service types from developers while still allowing the platform to translate application intent into the correct Kubernetes resource behavior.

### Abstract compute characteristics behind workload profiles

**Decision:** Use a simple `workloadProfile` setting such as `general`, `important`, or `critical` instead of exposing raw resource configuration directly to application teams.

**Reason:**
This demonstrates platform abstraction by allowing the platform to translate application intent into resource defaults and, in the future, potentially into node placement or scheduling behavior.

### Keep low-level Kubernetes scheduling settings platform-owned

**Decision:** Do not expose fields such as `nodeSelector`, `tolerations`, or `affinity` to developers in the chart interface.

**Reason:**
These are infrastructure and scheduling concerns that belong to the platform layer. Keeping them hidden supports a safer and simpler self-service experience.

### Use rolling updates in the Deployment strategy

**Decision:** Configure the Kubernetes Deployment to use a rolling update strategy with safe defaults.

**Reason:**
Rolling updates make new versions safer to release and are a standard expectation for production-style Kubernetes workloads.

### Add readiness and liveness probes to the application deployment

**Decision:** Configure both readiness and liveness probes for the application, using the `/health` endpoint.

**Reason:**
Health probes are required for reliable Kubernetes operation. Readiness controls when traffic is sent to the Pod, and liveness helps Kubernetes recover from unhealthy containers.

### Add a `/health` endpoint to the application

**Decision:** Add a dedicated `/health` route to the Flask application for Kubernetes health checks.

**Reason:**
A dedicated health endpoint is more reliable than probing the root path and makes liveness and readiness checks explicit and predictable.

### Use LoadBalancer service type for external testing in dev

**Decision:** Use a `LoadBalancer` Service when external browser access is needed in the `dev` environment.

**Reason:**
This is the simplest way to make the application reachable from outside the cluster during the current project stage, without yet introducing an Ingress controller.

### Use internal/public exposure as a platform abstraction over Kubernetes Service types

**Decision:** Model external accessibility as `internal` or `public` instead of directly exposing `ClusterIP` or `LoadBalancer` to developers.

**Reason:**
This makes the interface more intuitive for application teams and reinforces the idea that the platform owns the translation to raw Kubernetes objects.

### Use immutable image tags based on commit SHA for deployments

**Decision:** Deploy application images using immutable commit-based tags in the format `sha-<short-commit>`.

**Reason:**
Immutable tags provide reproducibility, traceability, and safer rollbacks. They are preferable to mutable tags such as `latest` for actual deployments.

### Keep `latest` only as a convenience tag, not as the deployment tag

**Decision:** Allow CI to continue pushing `latest` for convenience, but use only commit-SHA tags in Helm deployments.

**Reason:**
The `latest` tag can be useful for quick human reference, but it should not be used in the release path because it is mutable and not traceable.

### Separate CI and CD into different GitHub Actions workflows

**Decision:** Use one workflow for CI and a separate workflow for CD.

**Reason:**
CI and CD have distinct responsibilities. Separating them keeps the build and deployment logic cleaner and reflects common real-world pipeline design.

### Trigger CD only after successful CI on a push to `main`

**Decision:** Trigger the CD workflow only after the CI workflow completes successfully for a push to the `main` branch.

**Reason:**
This ensures that deployments happen only from validated changes merged into the main branch, while avoiding deployments from pull request builds.

### Use `workflow_run` to trigger CD from CI

**Decision:** Trigger the CD workflow using the GitHub Actions `workflow_run` event for the CI workflow.

**Reason:**
This creates an explicit dependency where deployment only occurs after the CI pipeline succeeds, while keeping CI and CD in separate workflow files.

### Recreate the image tag in CD from the commit SHA validated by CI

**Decision:** Recompute the image tag in CD from the same commit SHA used by the triggering CI run.

**Reason:**
Because CI and CD are separate workflows, CD must still identify the exact image to deploy. Reconstructing the SHA-based tag ensures it deploys the correct artifact.

### Deploy the exact commit validated by CI

**Decision:** Configure CD to deploy the exact commit that triggered the CI run rather than whatever happens to be latest on `main`.

**Reason:**
This avoids drift between the version built by CI and the version deployed by CD. It improves traceability and ensures the deployment matches the validated source state.

### Use `head_sha` from the triggering workflow in CD

**Decision:** Use the `workflow_run.head_sha` value to identify the exact commit that CI validated and CD should deploy.

**Reason:**
This ensures CD deploys the same source revision that CI built and tested, preventing mismatches caused by newer commits landing on `main` before CD starts.

### Check out the repository at the exact commit used by CI

**Decision:** Configure the CD workflow to check out the repository at the specific commit SHA associated with the triggering CI run.

**Reason:**
This guarantees that deployment uses the same chart and repository state that CI validated, rather than a newer state that may not match the built image.

### Use the same GitHub Actions IAM role for ECR push and EKS deployment access

**Decision:** Use the GitHub Actions IAM role not only for ECR push access but also for EKS deployment access.

**Reason:**
The deployment pipeline needs both image registry access and cluster access. Using one role keeps the authentication path simpler for this project.

### Grant the GitHub Actions role both AWS IAM access and EKS cluster access

**Decision:** Configure the GitHub Actions role with AWS permissions such as `eks:DescribeCluster` and also grant it access inside the EKS cluster.

**Reason:**
Successful EKS deployment requires two layers of access: AWS IAM permissions to interact with EKS APIs and authorization inside the cluster to run `kubectl` and Helm operations.

### Use a single environment (`prod`) for the current project scope

**Decision:** Complete the current project with a single working deployment environment (`prod`) and defer multi-environment design for a later phase.

**Reason:**
A working end-to-end implementation is more valuable for project completion than expanding to multiple environments before the core deployment story is finished.

### Defer multi-environment support until after the core deployment path is complete

**Decision:** Postpone the implementation of separate `dev` and `prod` deployment flows even though the design has already been discussed.

**Reason:**
The project already demonstrates the key platform concepts with one environment. Deferring multi-environment support helps maintain momentum and avoids overextending the scope before completion.