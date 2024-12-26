module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = "${var.prefix}-k8s-cluster"
  cluster_version = "1.31"

  cluster_endpoint_public_access = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.public_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium"]
  }

  eks_managed_node_groups = {
    addon_nodes = {
      vpc_security_group_ids = [module.eks.node_security_group_id, aws_security_group.worker_node_sg.id]
      ami_type               = "AL2023_x86_64_STANDARD"
      desired_size           = 2
      min_size               = 1
      max_size               = 4
    }
  }

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {
      configuration_values = jsonencode({
        enable-network-policy = true
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = {
    "karpenter.sh/discovery" = "${var.prefix}-k8s-cluster"
  }

  depends_on = [module.vpc]
}
