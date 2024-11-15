module "ebs-csi-driver" {
    count = var.enable_ebs_csi_driver ? 1 : 0
    source = "./ebs_csi_driver"
    prefix = var.prefix
    oidc_provider_arn = module.eks.oidc_provider_arn
    node_group_id = split(":", module.eks.eks_managed_node_groups.addon_nodes.node_group_id)[1]

    depends_on = [ module.eks ]
}