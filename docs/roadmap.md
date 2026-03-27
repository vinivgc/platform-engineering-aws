# Roadmap

## Phase 1 – Project Setup
- Repository structure
- Initial documentation

## Phase 2 – Terraform Foundation
- AWS provider setup
- Remote state (S3 + DynamoDB)
- Basic networking (VPC)

## Phase 3 – Kubernetes with EKS (Terraform)
- EKS cluster
- Access to kubectl 

## Phase 4 – Application
- Basic sample app
- Running in EKS
- Available for CI to build
- Available for ECR to store
- Available for EKS to run
- Simulate "developer changes"

## Phase 5 – CI pipeline (build + push image)
- GitHub Actions pipeline
- Automated build and check
- Push image to ECR

## Phase 6 – CD & Kubernetes + Helm
- Helm folder template
- Definition of Kubernetes service and deployment
- Document of deployment workflow
- Definition of platform abstractation (with Helm 'values.yaml' feature)

## Phase 7 – Self-Service
- Simplified deployment workflow for developers

## Phase 8 – Polish
- Documentation
- Architecture diagrams
- Interview preparation