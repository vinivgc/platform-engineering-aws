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

module "eks_cluster" {
  source = "../modules/eks-cluster"

  project_name                = var.project_name
  public_subnet_ids           = module.networking.public_subnet_ids
  private_subnet_ids          = module.networking.private_subnet_ids
  cluster_admin_principal_arn = var.cluster_admin_principal_arn

  cluster_version     = "1.33"
  node_instance_types = ["t3.medium"]
  node_capacity_type  = "ON_DEMAND"
  node_desired_size   = 2
  node_min_size       = 1
  node_max_size       = 3
  node_disk_size      = 20
}