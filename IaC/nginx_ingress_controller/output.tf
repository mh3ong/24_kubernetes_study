data "kubernetes_service" "nginx_ingress_controller" {
  metadata {
    name = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}

output "nlb_domain" {
  value = data.kubernetes_service.nginx_ingress_controller.status[0].load_balancer[0].ingress[0].hostname
}