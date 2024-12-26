module "ingress-controller-irsa-role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "${var.prefix}-ingress-controller-irsa-role"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["ingress-nginx:ingress-nginx-controller-sa"]
    }
  }
}

resource "helm_release" "nginx-ingress-controller" {
  namespace        = "ingress-nginx"
  create_namespace = true
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.11.3"
  wait             = true

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internet-facing"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-manage-backend-security-group-rules"
    value = "true"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-security-groups"
    value = var.nlb_sg_id
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-name"
    value = "${var.prefix}-ingress-nlb"
  }

  set {
    name  = "controller.service.targetPorts.http"
    value = "http"
  }

  set {
    name  = "controller.service.targetPorts.https"
    value = "https"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "ingress-nginx-controller-sa"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.ingress-controller-irsa-role.iam_role_arn
  }
}