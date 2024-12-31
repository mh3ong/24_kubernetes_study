resource "helm_release" "argocd" {
  name = "argocd"
  chart = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  namespace = "argocd"
  create_namespace = true

  values = [
    <<EOT
global:
  domain: ${var.nlb_domain}
configs:
  params:
    server.insecure: true
    server.basehref: /argocd
    server.rootpath: /argocd
server:
  ingress:
    enabled: true
    ingressClassName: "nginx"
    path: /argocd
EOT
  ]
}
