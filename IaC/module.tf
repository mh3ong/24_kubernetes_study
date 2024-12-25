module "ebs-csi-driver" {
  count             = var.enable_ebs_csi_driver ? 1 : 0
  source            = "./ebs_csi_driver"
  prefix            = var.prefix
  oidc_provider_arn = module.eks.oidc_provider_arn
  node_group_id     = split(":", module.eks.eks_managed_node_groups.addon_nodes.node_group_id)[1]

  depends_on = [module.eks]
}

module "efs-csi-driver" {
  count             = var.enable_efs_csi_driver ? 1 : 0
  source            = "./efs_csi_driver"
  prefix            = var.prefix
  oidc_provider_arn = module.eks.oidc_provider_arn
  node_group_id     = split(":", module.eks.eks_managed_node_groups.addon_nodes.node_group_id)[1]

  depends_on = [module.eks]
}

module "karpenter" {
  source            = "./karpenter"
  prefix            = var.prefix
  oidc_provider_arn = module.eks.oidc_provider_arn
  node_group_id     = split(":", module.eks.eks_managed_node_groups.addon_nodes.node_group_id)[1]
  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint

  providers = {
    aws          = aws
    aws.virginia = aws.virginia
  }
  depends_on = [module.eks]
}

module "prometheus" {
  count             = var.enable_prometheus ? 1 : 0
  source            = "./prometheus"

  depends_on = [module.eks, helm_release.nginx-ingress-controller]
}