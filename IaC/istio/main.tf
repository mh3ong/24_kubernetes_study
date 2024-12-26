
resource "helm_release" "istio" {
  name       = "istio-base"
  namespace  = "istio-system"
  chart      = "base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  version    = "1.24.2"

  create_namespace = true
}

resource "helm_release" "istio_discovery" {
  name       = "istiod"
  namespace  = "istio-system"
  chart      = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  version    = "1.24.2"

  depends_on = [helm_release.istio]

  values = [
    <<EOT
global:
  istioNamespace: istio-system
pilot:
  enabled: true
  k8s:
    serviceAnnotations:
      service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
EOT
  ]
}

resource "helm_release" "istio_ingress" {
  name       = "istio-ingress"
  namespace  = "istio-system"
  chart      = "gateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  version    = "1.24.2"

  depends_on = [helm_release.istio]

  values = [
    <<EOT
service:
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
    service.beta.kubernetes.io/aws-load-balancer-security-groups: ${var.nlb_sg_id}
    service.beta.kubernetes.io/aws-load-balancer-name: "${var.prefix}-istio-ingress-nlb"
    service.beta.kubernetes.io/aws-load-balancer-manage-backend-security-group-rules: "true"
EOT
  ]
}