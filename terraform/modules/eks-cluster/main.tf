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