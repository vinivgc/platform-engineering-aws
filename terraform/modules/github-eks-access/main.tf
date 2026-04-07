resource "aws_eks_access_entry" "this" {
  cluster_name  = var.eks_cluster_name
  principal_arn = aws_iam_role.this.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "cluster_admin" {
  cluster_name  = var.eks_cluster_name
  principal_arn = aws_iam_role.this.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}