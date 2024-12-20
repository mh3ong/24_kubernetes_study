resource "helm_release" "kube-prometheus-stack" {
  namespace  = "kube-system"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  name       = "kube-prometheus-stack"

  set {
    name = "grafana.adminPassword"
    value = "password"
  }

  set {
    name = "grafana.ingress.enabled"
    value = "true"
  }

  set {
    name = "grafana.ingress.ingressClassName"
    value = "nginx"
  }

  set {
    name = "grafana.ingress.path"
    value = "/monitor"
  }

  set {
    name = "grafana.grafana\\.ini.server.root_url"
    value = "%(protocol)s://%(domain)s/monitor"
  }

  set {
    name = "grafana.grafana\\.ini.server.serve_from_sub_path"
    value = "true"
  }
}
