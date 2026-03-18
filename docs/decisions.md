# Decisions

## 2026-03-17

### Use one repo instead of multiple repos
Reason: faster delivery, easier to explain in interviews, less operational overhead for a portfolio project.

---

### Start with a single dev environment
Reason: speed matters more than enterprise-grade environment separation for MVP.

---

## 2026-03-18

### Separate bootstrap from environment stacks

**Decision:** Place Terraform bootstrap in `terraform/bootstrap/` instead of under `environments/`.

**Reason:**
Bootstrap resources (S3 state bucket, DynamoDB lock table) are shared foundational infrastructure and not tied to a specific environment like dev or prod. Separating them improves clarity and reflects real-world structure.

---

### Use a single bootstrap stack for all environments

**Decision:** Use one bootstrap stack for dev, stage, and prod.

**Reason:**
Backend resources are shared across environments, while state isolation is handled via different state keys. This avoids unnecessary duplication and keeps the setup simple and maintainable.

---

### Isolate Terraform state per environment

**Decision:** Use different state keys per environment (e.g., `dev/`, `stage/`, `prod/`).

**Reason:**
State isolation prevents environments from interfering with each other and reduces the risk of accidental changes or destruction across environments.

---

### Avoid dynamic backend configuration

**Decision:** Keep backend configuration explicit per environment instead of trying to parameterize it.

**Reason:**
Terraform backend configuration is initialized separately from normal variables. Making it dynamic increases complexity and can lead to misconfiguration or accidental state overlap.

---

### Use local state first, then migrate to remote backend

**Decision:** Run bootstrap initially with local state, then optionally migrate to remote state.

**Reason:**
Backend resources must exist before they can be used. This avoids circular dependencies and follows Terraform’s initialization model.

---

### Use default_tags in provider configuration

**Decision:** Apply tags globally via `default_tags` instead of per resource.

**Reason:**
Ensures consistent tagging across all resources and reflects platform engineering practices where governance is enforced automatically.

---

### Tag bootstrap resources without environment tag

**Decision:** Apply `Project`, `Owner`, and `ManagedBy` tags, but not `Environment` in bootstrap.

**Reason:**
Bootstrap resources are shared and not tied to a single environment. Environment tags are applied in environment-specific stacks.

---

### Parameterize project naming

**Decision:** Use `project_name` variable for naming resources.

**Reason:**
Improves consistency, reusability, and makes it easier to adapt the configuration for other projects or environments.

---

### Protect critical backend resources

**Decision:** Use `prevent_destroy` on S3 bucket and DynamoDB table.

**Reason:**
Accidental deletion of Terraform state or lock table can break infrastructure management. Protection is applied where the operational risk is highest.

---

### Do not over-engineer early (no modules yet)

**Decision:** Avoid creating Terraform modules at the start.

**Reason:**
Abstraction too early leads to poor module design. It is better to understand actual usage patterns first, then extract reusable components.

---

### Use a monorepo structure

**Decision:** Keep infrastructure, application, and CI/CD in a single repository.

**Reason:**
Simplifies development, improves visibility, and is sufficient for a portfolio project while still reflecting real-world setups in smaller teams.

---

### Keep initial scope to a single environment (dev)

**Decision:** Start with only a dev environment.

**Reason:**
Prioritizes speed and learning. Additional environments can be added later once the core platform is working.
