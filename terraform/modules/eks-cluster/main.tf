resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-eks"
  role_arn = var.role_eks_cluster_arn

  vpc_config {
    subnet_ids = concat(
      var.private_subnet_ids,
    var.public_subnet_ids)
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name  = aws_eks_cluster.main.name
  subnet_ids    = var.private_subnet_ids
  node_role_arn = var.role_eks_nodes_arn

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }
}

resource "aws_eks_access_entry" "cluster_admin" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.cluster_admin_principal_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "cluster_admin" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.cluster_admin_principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}