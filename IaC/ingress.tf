resource "aws_security_group" "nlb_sg" {
  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "https"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
  }]

  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "alow all outbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]
  vpc_id = module.vpc.vpc_id

  tags = {
    "Name" = "${var.prefix}-nlb-sg"
  }
}

resource "aws_security_group" "worker_node_sg" {
  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "allow self"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = true
  }]

  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "alow all outbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]
  vpc_id = module.vpc.vpc_id

  tags = {
    "Name" = "${var.prefix}-worker-node-sg"
  }
}

module "aws-loadbalancer-controller-irsa-role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                              = "${var.prefix}-aws-lb-controller-sa-role"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller-sa"]
    }
  }
}

resource "helm_release" "aws-load-balancer-controller" {
  namespace  = "kube-system"
  name       = "aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  wait       = true

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller-sa"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.aws-loadbalancer-controller-irsa-role.iam_role_arn
  }

  set {
    name  = "replicaCount"
    value = "1"
  }

  set {
    name  = "nodeSelector.eks\\.amazonaws\\.com/nodegroup"
    value = split(":", module.eks.eks_managed_node_groups.addon_nodes.node_group_id)[1]
  }

  depends_on = [module.eks, module.aws-loadbalancer-controller-irsa-role]
}


