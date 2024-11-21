module "efs-csi-driver-role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "${var.prefix}-efs-csi-driver-sa-role"

  attach_efs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }
}

resource "helm_release" "efs-csi-driver" {
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart      = "aws-efs-csi-driver"
  name       = "aws-efs-csi-driver"

  set {
    name  = "controller.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "controller.serviceAccount.name"
    value = "efs-csi-controller-sa"
  }

  set {
    name  = "controller.replicas"
    value = 1
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.efs-csi-driver-role.iam_role_arn
  }

  set {
    name  = "controller.nodeSelector.eks\\.amazonaws\\.com/nodegroup"
    value = var.node_group_id
  }
}
