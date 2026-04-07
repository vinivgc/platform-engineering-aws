locals {
  oidc_issuer_hostpath = replace(var.eks_cluster_oidc_issuer_url, "https://", "")
  iam_policy_path      = "${path.module}/files/iam_policy.json"
}