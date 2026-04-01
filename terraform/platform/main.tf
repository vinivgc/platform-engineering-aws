module "networking" {
  source = "../modules/networking"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  eks_cluster_name     = "${var.project_name}-eks"
}

module "ecr" {
  source = "../modules/ecr"

  project_name = var.project_name
}

module "eks_access" {
  source = "../modules/eks-access"

  project_name = var.project_name
}

module "eks_cluster" {
  source = "../modules/eks-cluster"

  project_name         = var.project_name
  public_subnet_ids    = module.networking.public_subnet_ids
  private_subnet_ids   = module.networking.private_subnet_ids
  role_eks_cluster_arn = module.eks_access.role_cluster_arn
  role_eks_nodes_arn   = module.eks_access.role_nodes_arn

  depends_on = [module.eks_access]
}