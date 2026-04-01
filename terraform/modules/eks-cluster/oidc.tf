locals {
  cluster_oidc_issuer_url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url = local.cluster_oidc_issuer_url

  client_id_list = [
    "sts.amazonaws.com"
  ]
}