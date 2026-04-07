data "aws_region" "current" {}

resource "kubernetes_service_account_v1" "this" {
  depends_on = [
    aws_iam_role_policy_attachment.controller
  ]

  metadata {
    name      = var.service_account_name
    namespace = var.namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.this.arn
    }

    labels = {
      "app.kubernetes.io/name" = var.service_account_name
    }
  }
}

resource "helm_release" "this" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.chart_version
  namespace  = var.namespace

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 600

  depends_on = [
    kubernetes_service_account_v1.this
  ]

  values = [
    yamlencode({
      clusterName = var.eks_cluster_name
      region      = data.aws_region.current.region
      vpcId       = var.vpc_id

      serviceAccount = {
        create = false
        name   = var.service_account_name
      }

      enableServiceMutatorWebhook = var.enable_service_mutator_webhook
    })
  ]
}