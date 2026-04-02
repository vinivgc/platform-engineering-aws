locals {
  oidc_issuer_hostpath = replace(var.eks_cluster_oidc_issuer_url, "https://", "")
  service_account_name         = "aws-load-balancer-controller"
  service_account_namespace    = "kube-system"
  iam_policy_url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/${var.controller_version}/docs/install/iam_policy.json"
}