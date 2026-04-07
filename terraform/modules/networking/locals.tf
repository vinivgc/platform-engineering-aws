locals {
  public_subnet_kubernetes_tags = var.eks_cluster_name == null ? {} : {
    "kubernetes.io/role/elb"                        = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }

  private_subnet_kubernetes_tags = var.eks_cluster_name == null ? {} : {
    "kubernetes.io/role/internal-elb"               = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }
}