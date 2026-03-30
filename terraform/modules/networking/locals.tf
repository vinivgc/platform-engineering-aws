locals {
  public_k8s_tags = var.eks_cluster_name == null ? {} : {
    "kubernetes.io/role/elb"                        = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }

  private_k8s_tags = var.eks_cluster_name == null ? {} : {
    "kubernetes.io/role/internal-elb"               = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }
}