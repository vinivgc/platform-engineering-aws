data "aws_region" "current" {}

resource "kubernetes_service_account" "aws_load_balancer_controller" {
  depends_on = [
    aws_iam_role_policy_attachment.aws_load_balancer_controller
  ]

  metadata {
    name      = local.service_account_name
    namespace = local.service_account_namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_load_balancer_controller.arn
    }

    labels = {
      "app.kubernetes.io/name" = local.service_account_name
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version = var.chart_version
  namespace  = local.service_account_namespace

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 600

  depends_on = [
    kubernetes_service_account.aws_load_balancer_controller
  ]

  set = [ {
    name  = "clusterName"
    value = var.eks_cluster_name
  }, {
    name  = "region"
    value = data.aws_region.current.region
  }, {
    name  = "vpcId"
    value = var.vpc_id
  }, {
    name  = "serviceAccount.create"
    value = "false"
  }, {
    name  = "serviceAccount.name"
    value = local.service_account_name
  } ]
}