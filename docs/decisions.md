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