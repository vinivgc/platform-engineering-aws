module "github_actions_provider" {
  source = "../../modules/github-oidc-provider"
}

module "github_eks_access" {
  source = "../../modules/github-eks-access"

  eks_cluster_name                 = var.eks_cluster_name
  role_name                        = var.eks_role_name
  github_actions_oidc_provider_arn = module.github_actions_provider.github_actions_oidc_provider_arn
  github_org                       = var.github_org
  github_repo                      = var.github_repo
  github_branch                    = var.github_branch
}

module "github_ecr_access" {
  source = "../../modules/github-ecr-access"

  project_name                     = var.project_name
  ecr_repository_arn               = var.ecr_repository_arn
  role_name                        = var.ecr_role_name
  github_actions_oidc_provider_arn = module.github_actions_provider.github_actions_oidc_provider_arn
  github_org                       = var.github_org
  github_repo                      = var.github_repo
  github_branch                    = var.github_branch
}