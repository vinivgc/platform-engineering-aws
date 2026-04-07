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

### Use Helm as the standardized Kubernetes deployment layer

**Decision:** Use Helm instead of raw Kubernetes manifests as the deployment mechanism for the sample application.

**Reason:**
Helm provides templating, reuse, and parameterization, which better reflects a platform engineering approach than maintaining one-off YAML files.

### Replace raw Kubernetes test manifests with a reusable Helm chart

**Decision:** Replace the initial nginx-based test manifests with a reusable Helm chart for the sample application.

**Reason:**
The original manifests were only useful for validating EKS connectivity. A Helm chart better represents a real application deployment model and a reusable platform interface.

### Keep Terraform, CI, Helm, and CD as separate layers

**Decision:** Separate infrastructure provisioning, image build, deployment definition, and deployment execution into distinct layers.

**Reason:**
Terraform provisions infrastructure, CI builds and pushes images, Helm defines how the application runs in Kubernetes, and CD performs deployment. This separation improves clarity, maintainability, and architectural storytelling.

### Use `helm upgrade --install` as the standard deployment command

**Decision:** Use `helm upgrade --install` as the deployment command for the application.

**Reason:**
This makes deployments idempotent by installing the release if it does not exist and upgrading it if it does, which is appropriate for both manual validation and automated CD.

### Use the namespace as the environment boundary

**Decision:** Use Kubernetes namespaces such as `dev` and `prod` to represent environments.

**Reason:**
This keeps the chart environment-agnostic, supports reuse across environments, and aligns with standard Kubernetes deployment practices.

### Remove namespace management from the Helm chart

**Decision:** Do not create namespaces inside the Helm chart and instead manage the target namespace through Helm CLI flags.

**Reason:**
Namespace selection belongs to deployment context, not application definition. This keeps the chart reusable and avoids conflicts between chart templates and deployment commands.

### Use a single reusable Helm chart per application

**Decision:** Keep one Helm chart for the application rather than creating separate charts per environment.

**Reason:**
Deployment logic should be standardized and reused. Environment differences should be handled through values files or deployment inputs, not duplicated charts.

### Keep shared defaults in `values.yaml` and override only what changes

**Decision:** Use `values.yaml` for shared defaults and override only environment-specific or deployment-specific values.

**Reason:**
This keeps the base chart clean and avoids unnecessary duplication while allowing each environment to change only what it needs.

### Separate environment-specific values from the chart directory

**Decision:** Store environment-specific values files outside the Helm chart directory, for example under `k8s/values/sample-app/`.

**Reason:**
This separates deployment templates from environment configuration, keeps the chart reusable, and scales more cleanly as additional environments are added.

### Use environment-specific values files for dev and prod

**Decision:** Split configuration into environment-specific values files such as `dev.yaml` and `prod.yaml`.

**Reason:**
This makes environment differences explicit, keeps the chart reusable, and avoids long and hard-to-maintain chains of CLI overrides.

### Use pipeline overrides only for dynamic deployment-time values

**Decision:** Override only dynamic values such as the image tag from the deployment workflow.

**Reason:**
Static environment configuration should live in version-controlled values files, while runtime-specific values like the image version should be injected by the pipeline.

### Keep application environment variables in Helm values instead of CD overrides

**Decision:** Define application environment variables in Helm values rather than passing them through CD commands.

**Reason:**
These are part of deployment configuration, not dynamic runtime metadata. Keeping them in chart values improves separation of concerns and avoids unnecessary pipeline complexity.

### Use developer-friendly abstractions instead of exposing raw Kubernetes fields

**Decision:** Expose a small, platform-friendly configuration interface instead of low-level Kubernetes fields such as `nodeSelector`, `tolerations`, or `affinity`.

**Reason:**
Developers should express intent, not infrastructure internals. The platform should hide scheduling and infrastructure complexity behind safer abstractions.

### Abstract service exposure behind a simple platform input

**Decision:** Expose service accessibility through a simple setting such as `exposure.type: internal|public`.

**Reason:**
This hides raw Kubernetes service types from developers while allowing the platform to translate application intent into the correct Service behavior.

### Abstract resource behavior behind workload profiles

**Decision:** Use a simplified `workloadProfile` input such as `general`, `important`, or `critical`.

**Reason:**
This demonstrates platform abstraction by allowing the platform to map intent to resource defaults and future scheduling behavior without exposing raw Kubernetes resource configuration directly.

### Keep low-level Kubernetes scheduling settings platform-owned

**Decision:** Do not expose low-level scheduling settings such as `nodeSelector`, `tolerations`, or `affinity` to developers.

**Reason:**
These are platform concerns, not application concerns. Hiding them reduces developer cognitive load and preserves platform control.

### Use rolling updates in the Deployment strategy

**Decision:** Configure the Kubernetes Deployment to use a rolling update strategy.

**Reason:**
Rolling updates are a production-style default that support safer releases and minimize service disruption during application updates.

### Add readiness and liveness probes based on `/health`

**Decision:** Configure both readiness and liveness probes using the application’s `/health` endpoint.

**Reason:**
Health probes are required for reliable Kubernetes operations. They ensure traffic is sent only to healthy Pods and allow Kubernetes to recover unhealthy containers.

### Use numeric probe ports instead of named ports

**Decision:** Configure readiness and liveness probes to use the numeric application port rather than a named container port reference.

**Reason:**
This avoids failures caused by named port resolution issues and keeps the probe configuration simpler and more robust for the current project.

### Align the application, container, and Kubernetes configuration on port `5000`

**Decision:** Standardize the Python application, Docker image, and Helm chart around port `5000`.

**Reason:**
The Flask application listens on port `5000`, so the container and Kubernetes configuration should match that value exactly to avoid connectivity and probe failures.

### Expose the application on `0.0.0.0` inside the container

**Decision:** Configure the Python application to listen on `0.0.0.0` instead of `127.0.0.1`.

**Reason:**
Applications running in containers must bind to all interfaces to be reachable through Kubernetes networking and Services.

### Add a dedicated `/health` endpoint to the application

**Decision:** Add a `/health` endpoint to the Flask application for Kubernetes probes.

**Reason:**
A dedicated health endpoint is more reliable than probing the root path and makes health checking explicit and predictable.

### Use a Service port of `80` and forward to container port `5000`

**Decision:** Expose the Kubernetes Service on port `80` and forward traffic to the application container port `5000`.

**Reason:**
This creates a cleaner external interface while allowing the application to keep its internal runtime port unchanged.

### Use a LoadBalancer service in dev for external access

**Decision:** Use a `LoadBalancer` Service when external browser access is needed in the `dev` environment.

**Reason:**
This is the simplest way to make the application reachable externally during the current project stage without introducing an Ingress controller yet.

### Use immutable image tags based on commit SHA for deployments

**Decision:** Deploy images using immutable commit-based tags in the format `sha-<short-commit>`.

**Reason:**
Immutable tags improve traceability, reproducibility, and rollback safety compared to mutable tags such as `latest`.

### Keep `latest` only as a convenience tag

**Decision:** Allow CI to continue publishing `latest` as a convenience tag, but use only SHA-based tags for deployments.

**Reason:**
`latest` can be useful for quick manual reference, but it should not be used in the deployment path because it is mutable and not traceable.

### Keep the current CI pipeline and optimize later

**Decision:** Keep the current working CI design unchanged instead of refactoring it prematurely.

**Reason:**
The existing CI pipeline already supports the required build-and-push flow. Prioritizing forward progress over unnecessary optimization keeps the project moving.

### Separate CI and CD into different GitHub Actions workflows

**Decision:** Use one GitHub Actions workflow for CI and a separate workflow for CD.

**Reason:**
Build and deployment are distinct responsibilities. Separating them keeps the workflows simpler and more aligned with real-world delivery pipelines.

### Trigger dev CD only after successful CI on a push to `main`

**Decision:** Trigger the development deployment workflow only after the CI workflow completes successfully for a push to `main`.

**Reason:**
This ensures that only validated changes merged into the main branch are deployed, while avoiding deployments from pull request builds.

### Use `workflow_run` to trigger CD from CI

**Decision:** Trigger the dev CD workflow using the GitHub Actions `workflow_run` event on successful CI completion.

**Reason:**
This creates an explicit dependency between build success and deployment while keeping CI and CD in separate workflow files.

### Recreate the image tag in CD from the same commit validated by CI

**Decision:** Recompute the image tag in CD from the same commit SHA used by the triggering CI run.

**Reason:**
Because CI and CD are separate workflows, CD still needs a reliable way to identify the exact image artifact to deploy.

### Deploy the exact commit validated by CI to dev

**Decision:** Configure dev CD to deploy the exact commit that triggered the CI run.

**Reason:**
This avoids drift between the version built by CI and the version deployed by CD, improving traceability and consistency.

### Use `head_sha` from the triggering workflow in dev CD

**Decision:** Use `workflow_run.head_sha` to identify the exact commit that CI validated and dev CD should deploy.

**Reason:**
This ensures dev CD uses the same source revision that CI built and tested, even if newer commits land on `main` before deployment begins.

### Check out the repository at the exact commit used by CI in dev CD

**Decision:** Configure the dev CD workflow to check out the repository at the specific commit SHA associated with the triggering CI run.

**Reason:**
This guarantees that the deployed chart and repository state match the same commit used to build the image.

### Treat workflows as versioned code tied to commits

**Decision:** Apply workflow changes through new commits and pushes instead of relying on re-running older workflow runs.

**Reason:**
GitHub Actions re-runs use the workflow definition from the original commit. Treating workflows as versioned code avoids confusion and ensures changes take effect predictably.

### Use the same GitHub Actions IAM role for ECR and EKS access

**Decision:** Use the GitHub Actions IAM role both for pushing images to ECR and for deploying to EKS.

**Reason:**
The pipeline needs access to both the image registry and the cluster. Reusing the same role keeps authentication simpler for this project.

### Grant the GitHub Actions role both AWS IAM permissions and EKS cluster access

**Decision:** Configure the GitHub Actions role with both AWS API permissions, such as `eks:DescribeCluster`, and access inside the EKS cluster.

**Reason:**
Successful deployment requires both layers: AWS IAM permissions to interact with EKS APIs and in-cluster authorization to run Helm and kubectl operations.

### Align CD cluster configuration with the actual provisioned EKS cluster name

**Decision:** Configure the deployment workflows to target the exact EKS cluster name provisioned by Terraform.

**Reason:**
A mismatch between the cluster name in IAM/Terraform and the workflow causes authorization failures even when permissions are otherwise correct.

### Validate the Helm deployment manually before automating it

**Decision:** Validate the Helm deployment manually from the local machine before relying fully on CD.

**Reason:**
This confirms that the chart, image, service, and probes work correctly before debugging them through the added complexity of pipeline automation.

### Treat manual Helm deployment as a validation step, not the final operating model

**Decision:** Use manual Helm deployment only as an intermediate validation step while building the platform.

**Reason:**
The purpose of the manual step is to verify the deployment layer. The intended final state remains automated deployment through CD workflows.

### Use a single shared `dev` namespace for the current project scope

**Decision:** Use one shared `dev` namespace for automatic development deployments instead of implementing per-developer namespaces now.

**Reason:**
A shared `dev` namespace keeps the project simpler and is sufficient for demonstrating the end-to-end platform flow. Per-developer namespaces are a valid future enhancement but add unnecessary complexity for the current scope.

### Use manual promotion for production deployments

**Decision:** Deploy to `dev` automatically after successful CI on `main`, but promote to `prod` through a manually triggered GitHub Actions workflow using a selected immutable image tag.

**Reason:**
This keeps development fast while maintaining control over production releases. It also ensures the same built artifact is promoted across environments instead of being rebuilt, improving traceability and consistency.

### Use image-tag-based manual promotion for prod

**Decision:** Implement the manual production workflow so that the user selects an existing immutable image tag rather than rebuilding the application for production.

**Reason:**
This follows the “build once, promote many” model, where CI creates deployable artifacts and promotion chooses which tested artifact moves forward.

### Keep prod workflow inputs minimal and platform-owned

**Decision:** Limit the manual production deployment workflow input to the image tag and keep namespace, release name, chart path, and deployment details fixed in the workflow.

**Reason:**
This exposes a simple self-service interface while ensuring that platform-owned deployment details remain standardized and controlled.

### Use plain checkout in the manual prod workflow instead of checking out by image tag

**Decision:** Do not use the selected Docker image tag as the checkout ref in the manual production workflow.

**Reason:**
The image tag is an ECR artifact identifier, not a Git ref. `actions/checkout` expects a branch, tag, or commit from the repository, so using the image tag there would be incorrect.

## 2026-03-31

### Separate platform infrastructure from CI/CD access infrastructure

**Decision:** Keep core AWS platform resources in `terraform/platform/` and GitHub Actions IAM/OIDC access in `terraform/platform-access/github-actions/`.

**Reason:**
The platform stack owns long-lived runtime infrastructure such as networking, EKS, and ECR. The GitHub Actions stack owns CI/CD access concerns such as OIDC trust and IAM roles. This separation keeps responsibilities clear and makes the architecture easier to explain in interviews.

### Keep Terraform root stacks independent and compose them through scripts

**Decision:** Avoid direct Terraform stack coupling for platform-to-access wiring, and instead orchestrate the stacks through shell scripts.

**Reason:**
This keeps each Terraform root focused on its own responsibility and avoids embedding backend/state knowledge from one stack into another. Shared values and handoffs are handled at the workflow layer, which is a clean and realistic pattern for infrastructure repositories.

### Pass shared root inputs consistently through generated Terraform variable files

**Decision:** Use generated `terraform.auto.tfvars.json` files in scripts to pass shared inputs such as `aws_region` and `project_name` into Terraform root stacks.

**Reason:**
This standardizes how root stacks receive configuration, keeps Terraform inputs explicit, and avoids mixing multiple patterns such as local shell-only config for one stack and file-based config for another.

### Pass platform outputs to downstream stacks through the orchestration layer

**Decision:** Read platform outputs such as `cluster_name` and `ecr_repository_arn` after applying the platform stack, and pass them into the GitHub Actions access stack through generated Terraform variables.

**Reason:**
These values are produced by the platform stack but consumed by the access stack. Passing them through the orchestration layer preserves clean stack boundaries while still allowing the repository to manage the full end-to-end flow.

### Keep GitHub trust configuration local to the GitHub Actions stack

**Decision:** Keep values such as `github_org`, `github_repository`, `github_branch`, and GitHub Actions IAM role names in `terraform/platform-access/github-actions/`.

**Reason:**
These values are access-policy decisions, not platform outputs. Keeping them local to the GitHub Actions stack preserves separation of concerns and avoids overloading platform state with unrelated configuration.

### Use explicit module dependency for EKS IAM readiness

**Decision:** Add an explicit dependency from the EKS cluster module to the EKS access/IAM module.

**Reason:**
The cluster and managed node group require IAM roles and policy attachments to be fully in place before creation. An explicit dependency makes apply ordering safer and avoids IAM-related provisioning issues.

### Make Kubernetes subnet tagging explicit instead of relying on hidden naming contracts

**Decision:** Remove implicit Kubernetes subnet tagging based on hardcoded naming assumptions inside the networking module and make EKS-related tagging an explicit input.

**Reason:**
This avoids hidden coupling between networking and EKS. The dependency still exists when EKS is used, but it is now visible at the composition layer instead of being buried inside module internals.

### Harden the Terraform backend bucket beyond backend encryption settings

**Decision:** Add S3 bucket hardening for Terraform state, including bucket encryption configuration and public access blocking.

**Reason:**
Terraform backend encryption settings help protect the state object, but bucket-level hardening improves the default security posture of the backend itself and reduces the risk of accidental exposure.

### Keep AWS authentication outside Terraform variables

**Decision:** Remove `aws_profile` from Terraform variables and provide AWS authentication through environment variables in scripts.

**Reason:**
AWS profile selection is local execution context, not infrastructure configuration. Keeping it outside Terraform makes the root modules cleaner and avoids mixing operator-specific settings with declarative infrastructure inputs.

### Keep the project intentionally simple and optimize for clarity over maximum abstraction

**Decision:** Prefer a clear, interview-friendly Terraform structure over adding excessive validation, abstraction, or generalized logic.

**Reason:**
The goal of the project is to demonstrate sound platform engineering judgment, not to simulate a full enterprise framework. Simplicity makes the design easier to review and easier to explain while still showing strong engineering decisions.

### Use automatic deployment for dev and manual promotion for prod

**Decision:** Deploy automatically to dev after a successful CI run on `main`, and require a manual workflow dispatch with an explicit image tag for prod.

**Reason:**
Dev should provide fast feedback and continuous integration, while prod should remain controlled and traceable. This also demonstrates a clear promotion model using immutable artifacts.

### Store shared pipeline configuration in GitHub repository variables

**Decision:** Move shared CI/CD settings such as AWS region, role ARN, cluster name, ECR repository, chart path, and app path into GitHub repository variables.

**Reason:**
These values are runtime pipeline configuration, not workflow logic. Keeping them outside the workflow files reduces hardcoding while preserving a simple and explicit design.

### Store environment-specific deployment settings in GitHub Environments

**Decision:** Use GitHub Environments such as `dev` and `prod` to hold environment-specific values like Kubernetes namespace.

**Reason:**
This keeps environment concerns separate from shared pipeline concerns, avoids duplicating workflow logic, and creates a cleaner path for future environment protections such as approvals.

### Do not make CI/CD pipelines depend directly on Terraform outputs at runtime

**Decision:** Do not fetch Terraform outputs from within CI/CD workflows, and do not connect deployment workflows directly to Terraform state.

**Reason:**
This avoids coupling application delivery to infrastructure state and keeps the boundary between provisioning and deployment clear. It also keeps the workflows simpler, more reliable, and easier to explain.

### Prevent overlapping deployments with workflow concurrency

**Decision:** Add concurrency control to CD workflows, cancelling stale in-progress runs for dev and allowing only one prod deployment at a time.

**Reason:**
This reduces deployment conflicts and reflects good operational discipline without adding much complexity. It is a small improvement that strengthens the platform engineering side of the project.

### Keep the CI/CD design intentionally simple and explicit

**Decision:** Prefer a clear and interview-friendly CI/CD structure over more dynamic or highly abstract patterns.

**Reason:**
The purpose of the project is to demonstrate sound platform engineering judgment. A simpler design makes the architecture easier to understand, easier to maintain, and easier to defend in interviews.

## 2026-04-07

### Expose autoscaling through a platform-oriented scaling contract

**Decision:** Expose autoscaling through a simplified `scaling` interface with fields such as `enabled`, `minReplicas`, `maxReplicas`, `targetCPUUtilization`, and `profile`, instead of exposing raw Kubernetes HPA behavior fields directly.

**Reason:**
This keeps the developer-facing interface focused on intent rather than Kubernetes internals. The chart owns the detailed HPA behavior, which makes the platform easier to consume and easier to explain in interviews.

### Install Metrics Server as a platform add-on managed by Terraform

**Decision:** Install Metrics Server in the `platform-addons` Terraform stack using the official Helm chart.

**Reason:**
Metrics Server is cluster-level platform functionality required by HPA and `kubectl top`, so it belongs with other shared add-ons rather than inside the application chart or workload configuration.

### Standardize safe Helm release behavior for platform add-ons

**Decision:** Use `atomic = true`, `cleanup_on_fail = true`, `wait = true`, and an explicit timeout for Helm-managed platform add-ons.

**Reason:**
These settings make add-on installation and upgrades safer and more predictable by avoiding partially failed releases and ensuring Terraform waits for resources to become ready.

### Expose ingress through a small developer-facing contract and keep ALB details inside the platform

**Decision:** Keep the developer-facing ingress configuration limited to values such as `enabled`, `host`, `path`, and `visibility`, while keeping AWS ALB annotations and ingress class details inside the chart.

**Reason:**
This allows developers to express exposure intent without needing to understand controller-specific implementation details. It creates a cleaner platform boundary and avoids leaking AWS-specific complexity into application configuration.

### Expose pod security through a security profile instead of raw securityContext fields

**Decision:** Expose pod hardening through a small `security.profile` interface, and keep the concrete Kubernetes `securityContext` settings inside the chart.

**Reason:**
This keeps security defaults consistent and reduces the need for developers to understand low-level Kubernetes security options. It also creates a stronger platform story by showing that the platform owns secure workload defaults.

### Run the sample application as a non-root container

**Decision:** Update the sample application image and Kubernetes settings to run as a dedicated non-root user, including `runAsNonRoot`, explicit UID/GID, disabled privilege escalation, dropped Linux capabilities, and `RuntimeDefault` seccomp.

**Reason:**
This aligns the workload with common Kubernetes hardening guidance without adding unnecessary complexity. It also makes the security context meaningful instead of being only declarative.

### Expose disruption protection through an availability profile

**Decision:** Expose PodDisruptionBudget behavior through an `availability.profile` value such as `none`, `standard`, or `critical`, instead of exposing raw PDB fields like `minAvailable` and `maxUnavailable`.

**Reason:**
This lets developers choose the level of protection they need without dealing with Kubernetes disruption policy details. The platform remains responsible for the exact PDB implementation.

### Improve health checks by separating startup, liveness, and readiness concerns

**Decision:** Split the sample application's health behavior into distinct startup, liveness, and readiness paths, and use Kubernetes startup, liveness, and readiness probes accordingly.

**Reason:**
This makes the deployment behavior more realistic and better reflects how real workloads should behave in Kubernetes. It also improves the platform story by showing that traffic routing and restart behavior are based on meaningful application signals.

### Keep runtime configuration simple and focused on meaningful operational settings

**Decision:** Externalize only a small set of meaningful runtime settings for the sample application, such as environment, message, and readiness-related behavior, instead of turning all metadata into configuration.

**Reason:**
Not every constant needs to become runtime config. Keeping only meaningful operational settings externalized avoids noise, reduces duplication, and keeps the sample application simple.

### Use a Helm-managed ConfigMap for non-secret application runtime configuration

**Decision:** Generate a ConfigMap from Helm values and inject it into the application with `envFrom` for non-sensitive runtime settings.

**Reason:**
This creates a clearer separation between workload definition and runtime configuration while keeping the implementation simple. It improves the platform design without introducing unnecessary complexity such as manual ConfigMap management or secrets handling.

### Keep the Service interface simple by deriving targetPort from the application port

**Decision:** Keep the Service interface simple by mapping the Service port to the application port, and avoid exposing unnecessary Service port configuration to developers.

**Reason:**
This reduces duplication and prevents misconfiguration between service and container ports. It also keeps the platform contract focused on the application’s listening port while preserving a clean Service convention.

### Keep the AWS Load Balancer Controller in a dedicated platform-addons stack

**Decision:** Manage the AWS Load Balancer Controller in the `platform-addons` Terraform stack instead of placing it inside the core platform infrastructure stack.

**Reason:**
The controller is a cluster addon, not foundational infrastructure like VPC or EKS itself. Keeping it in the addons layer preserves a cleaner boundary between base platform provisioning and operational cluster capabilities.

### Use IRSA for the AWS Load Balancer Controller

**Decision:** Grant AWS permissions to the AWS Load Balancer Controller through IAM Roles for Service Accounts (IRSA) instead of relying on broad node-level permissions.

**Reason:**
This follows the recommended EKS pattern, keeps permissions scoped to the controller, and demonstrates a cleaner and more production-aligned integration between AWS IAM and Kubernetes service accounts.

### Create the controller service account outside Helm and bind it to IAM explicitly

**Decision:** Create the `aws-load-balancer-controller` Kubernetes service account in Terraform and configure the Helm chart to reuse it with `serviceAccount.create = false`.

**Reason:**
This keeps the IRSA relationship explicit and reliable. The IAM role annotation lives on a Terraform-managed service account, while Helm is only responsible for installing the controller itself.

### Pass AWS Load Balancer Controller versions explicitly from the caller module

**Decision:** Define the AWS Load Balancer Controller chart version and controller version in `platform-addons` and pass them explicitly into the `alb-controller` module.

**Reason:**
This avoids hidden module defaults, makes upgrades intentional, and ensures the addon version used by the module matches the version declared by the caller.

### Pin upstream vendor IAM policies in the repository instead of downloading them during Terraform apply

**Decision:** Store the AWS Load Balancer Controller IAM policy JSON in the repository and load it from a local file instead of fetching it from GitHub at apply time.

**Reason:**
This makes Terraform runs more deterministic, removes an unnecessary runtime dependency on an external source, and makes the exact vendor policy version visible and reviewable in Git.

### Use Terraform-native IAM policy documents for small project-owned policies and pinned JSON files for large vendor-managed policies

**Decision:** Keep custom project policies such as GitHub Actions access policies defined with `aws_iam_policy_document`, while using locally pinned JSON files for large upstream-managed policies such as the AWS Load Balancer Controller policy.

**Reason:**
Small project-owned policies are easier to understand and maintain inline in Terraform, while large vendor-managed policies are clearer and safer when preserved in their upstream structure and version-pinned in the repository.

### Keep the AWS Load Balancer Controller module focused only on controller concerns

**Decision:** Limit the `alb-controller` module inputs and resources to controller-specific concerns such as IRSA, Helm installation, naming, and controller settings, and remove unrelated variables.

**Reason:**
A focused module is easier to understand, easier to explain in interviews, and less likely to accumulate copy-paste configuration that does not belong to the controller itself.

### Derive AWS region from the provider inside the AWS Load Balancer Controller module

**Decision:** Use `data.aws_region.current` inside the `alb-controller` module instead of passing AWS region in as a module input.

**Reason:**
The region is already known by the configured AWS provider, so deriving it inside the module reduces unnecessary wiring and avoids mismatches between provider configuration and caller-supplied variables.

### Keep namespace and service account identity explicit in the AWS Load Balancer Controller module

**Decision:** Represent the controller namespace and service account name explicitly in the module and use them consistently in the Kubernetes service account, Helm values, and IAM trust policy.

**Reason:**
The controller IAM role trust relationship depends on the exact Kubernetes service account identity. Making these values explicit improves clarity and prevents subtle IRSA misalignment.

### Make controller behavior explicit instead of relying on chart defaults

**Decision:** Expose important AWS Load Balancer Controller behavior such as `enableServiceMutatorWebhook` as an explicit module setting rather than relying silently on Helm chart defaults.

**Reason:**
This makes the module easier to reason about, makes behavior changes more visible during review, and shows deliberate control over addon behavior rather than accidental dependence on defaults.

### Keep the AWS Load Balancer Controller implementation simple and document CRD upgrade considerations instead of automating full CRD lifecycle management

**Decision:** Do not add full CRD lifecycle automation to the `alb-controller` module, but explicitly acknowledge that controller upgrades may require CRD handling outside normal Helm upgrade behavior.

**Reason:**
For this project, the main value is showing sound platform engineering structure, addon integration, and developer-facing platform capabilities. Full CRD lifecycle automation would add complexity that is real but not central to the project’s main signal.

### Use the official AWS Load Balancer Controller IAM policy as the baseline for the project

**Decision:** Use the official AWS Load Balancer Controller IAM policy as the baseline policy for this project instead of spending project scope on aggressive least-privilege customization.

**Reason:**
The project is intended to highlight platform architecture, EKS addon integration, and how the platform serves developers. Using the recommended policy keeps the implementation clear, while still leaving room to explain that production hardening could further scope permissions down if needed.








### Merge EKS IAM role creation into the EKS cluster module

**Decision:** Move EKS control plane and node group IAM role creation into the `eks-cluster` module instead of keeping a separate `eks-access` module.

**Reason:**
The IAM roles for the EKS cluster and managed nodes are foundational cluster plumbing, not a separate access capability. Keeping them inside `eks-cluster` makes the module boundary clearer, simplifies the root stack, and avoids misleading naming.

### Keep Terraform module granularity focused on platform capabilities

**Decision:** Keep modules aligned to clear platform capabilities such as `networking`, `ecr`, `eks-cluster`, `github-oidc-provider`, `github-ecr-access`, `github-eks-access`, `alb-controller`, and `metrics-server`, and avoid splitting them into smaller modules without a strong readability benefit.

**Reason:**
The goal of the project is to highlight platform engineering judgment, not maximum module granularity. Capability-based modules are easier to explain in interviews, keep the codebase readable, and avoid turning the project into a Terraform abstraction exercise.

### Keep GitHub ECR and EKS access as separate modules

**Decision:** Use separate modules for GitHub access to ECR and GitHub access to EKS instead of merging them into one generic GitHub IAM module.

**Reason:**
These represent different trust and permission boundaries: one for image publishing and one for cluster deployment. Keeping them separate makes the delivery model clearer and shows deliberate platform access design.

### Keep the GitHub OIDC provider as a shared standalone module

**Decision:** Manage the GitHub OIDC provider in its own module and reuse it from the GitHub access modules.

**Reason:**
The OIDC provider is a shared trust anchor, not a permission set tied to one workflow. Keeping it separate makes the design clearer and avoids duplicating identity foundation logic.

### Keep cluster add-ons modular but not over-split

**Decision:** Keep `alb-controller` and `metrics-server` as separate add-on modules, but do not split them further into separate IAM-only and Helm-only modules.

**Reason:**
These add-ons are distinct platform capabilities, but splitting each into smaller submodules would add indirection without making the platform design stronger. A single module per add-on keeps the code simpler and easier to review.

### Standardize module interfaces around explicit public inputs and outputs

**Decision:** Standardize equivalent module inputs and outputs using consistent names such as `github_actions_oidc_provider_arn` and `iam_role_arn`.

**Reason:**
Consistent module interfaces make the codebase easier to navigate, reduce confusion between similar modules, and make the overall design look intentional rather than incrementally assembled.

### Use shorter internal Terraform object names where the module already provides context

**Decision:** Prefer concise internal names such as `assume_role`, `this`, `eks_access`, and `cluster_admin` for resources, data sources, and locals inside small modules, while keeping explicit names in modules that manage multiple similar resources.

**Reason:**
The module name already provides context. Shorter internal names reduce repetition and improve scanability, while explicit names remain useful in modules like `eks-cluster` and `networking` where multiple parallel resources exist.

### Remove dead Terraform variables instead of exposing unused configurability

**Decision:** Remove module and root variables that do not control real behavior, such as the unused ALB controller version input.

**Reason:**
Unused variables create the impression of configurability without actually affecting infrastructure behavior. This makes modules harder to trust and understand, especially in an interview setting.

### Use chart-specific version inputs instead of ambiguous version variables

**Decision:** When exposing a version for Helm-managed add-ons, use a precise name such as `chart_version` rather than a generic name like `controller_version`.

**Reason:**
A precise name makes it clear what is actually being versioned and avoids ambiguity between chart version, application version, IAM policy version, or module version.

### Keep provider configuration at the root and avoid passing unnecessary environment context into modules

**Decision:** Configure providers in root stacks and only pass module inputs that represent meaningful infrastructure choices, avoiding unnecessary variables such as passing `aws_region` when the module already reads it internally or does not need it.

**Reason:**
This keeps module interfaces smaller, reduces duplication, and makes the distinction between execution context and infrastructure configuration clearer.

### Use explicit cluster and node defaults as part of the EKS module interface

**Decision:** Keep a small set of meaningful EKS settings explicit, such as cluster version, node instance types, node capacity type, and node scaling values.

**Reason:**
These are real platform decisions and useful interview talking points. Making them explicit improves clarity without overengineering the module.

### Derive names internally for platform-owned resources by default

**Decision:** For platform-owned resources such as internal IAM roles and repositories, derive names inside modules from `project_name` unless there is a strong reason to make the full name an input.

**Reason:**
This keeps module interfaces simpler and makes naming more consistent across foundational platform resources.

### Allow explicit role names only for external integration boundaries

**Decision:** Allow explicit `role_name` inputs for external integration modules such as `github-ecr-access` and `github-eks-access`, while preferring internally derived names for platform-owned roles.

**Reason:**
External integration roles are more likely to benefit from caller-controlled naming for clarity and future flexibility. Internal platform roles are easier to manage and standardize when named inside the module.

### Keep networking as a single cohesive module

**Decision:** Manage the VPC, subnets, routing, internet gateway, NAT gateway, and Kubernetes subnet tagging in one `networking` module instead of splitting them into smaller modules.

**Reason:**
These resources form one coherent networking capability. Keeping them together improves readability and avoids unnecessary abstraction.

### Accept simple networking tradeoffs when they are deliberate and explainable

**Decision:** Keep the networking design intentionally simple, including choices such as a single NAT gateway, and explain the tradeoff rather than abstracting around it.

**Reason:**
The project is intended to demonstrate sound judgment, not maximum enterprise completeness. A conscious simplicity tradeoff is easier to justify and discuss than added complexity with little platform value.

### Keep subnet validation optional and avoid adding complexity without clear payoff

**Decision:** Do not add extra Terraform validation for subnet list shape when the design assumption can be explained clearly and the added validation would make the code more complex than useful.

**Reason:**
Not every reasonable assumption needs to be enforced in code for a personal project. Avoiding low-value complexity keeps the implementation cleaner while still allowing the design choice to be discussed in interviews.