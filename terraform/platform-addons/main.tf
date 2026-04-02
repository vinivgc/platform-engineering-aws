module "aws_load_balancer_controller" {
  source = "../modules/alb-controller"

  project_name = var.project_name
  eks_cluster_name = var.eks_cluster_name
  eks_cluster_oidc_issuer_url = var.eks_cluster_oidc_issuer_url
  eks_cluster_oidc_provider_arn = var.eks_cluster_oidc_provider_arn
  vpc_id = var.eks_cluster_vpc_id
  role_name = var.aws_load_balancer_controller_role_name
}