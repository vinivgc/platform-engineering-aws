resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}

resource "aws_iam_role" "github_actions" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

resource "aws_iam_policy" "github_actions_eks_access" {
  name   = "${var.role_name}-eks-access-policy"
  policy = data.aws_iam_policy_document.github_actions_eks_access.json
}

resource "aws_iam_policy" "github_actions_ecr_push" {
  name   = "${var.project_name}-ecr-push-policy"
  policy = data.aws_iam_policy_document.github_actions_ecr_push.json
}

resource "aws_iam_role_policy_attachment" "github_actions_eks_access" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_eks_access.arn
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr_push" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_ecr_push.arn
}