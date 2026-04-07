data "aws_region" "current" {}

resource "kubernetes_service_account" "aws_load_balancer_controller" {
  depends_on = [
    aws_iam_role_policy_attachment.aws_load_balancer_controller
  ]

  metadata {
    name      = var.service_account_name
    namespace = var.namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_load_balancer_controller.arn
    }

    labels = {
      "app.kubernetes.io/name" = var.service_account_name
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
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
    kubernetes_service_account.aws_load_balancer_controller
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