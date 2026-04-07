data "aws_iam_policy_document" "assume_role" {
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
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_hostpath}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "controller" {
  name   = "${var.project_name}-aws-load-balancer-controller-policy"
  policy = file(local.iam_policy_path)

  tags = {
    Name = "${var.project_name}-aws-load-balancer-controller-policy"
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.project_name}-aws-load-balancer-controller-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Name = "${var.project_name}-aws-load-balancer-controller-role"
  }
}

resource "aws_iam_role_policy_attachment" "controller" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.controller.arn
}