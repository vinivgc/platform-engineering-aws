resource "aws_iam_role" "this" {
  name               = "${var.project_name}-github-eks-${var.github_environment}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "eks_access" {
  name   = "${aws_iam_role.this.name}-policy"
  policy = data.aws_iam_policy_document.eks_access.json
}

resource "aws_iam_role_policy_attachment" "eks_access" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.eks_access.arn
}