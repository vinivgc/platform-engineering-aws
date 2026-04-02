data "http" "aws_load_balancer_controller_iam_policy" {
  url = local.iam_policy_url
}

data "aws_iam_policy_document" "aws_load_balancer_controller_assume_role" {
  statement {
    sid     = "AllowAssumeRoleWithWebIdentity"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.eks_cluster_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_hostpath}:sub"
      values   = ["system:serviceaccount:${local.service_account_namespace}:${local.service_account_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_hostpath}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "${var.project_name}-aws-load-balancer-controller-policy"
  policy      = data.http.aws_load_balancer_controller_iam_policy.response_body
}

resource "aws_iam_role" "aws_load_balancer_controller" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume_role.json
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  role       = aws_iam_role.aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}