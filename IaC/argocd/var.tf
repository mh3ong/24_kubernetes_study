data "kubernetes_service" "nginx_ingress_controller" {
  metadata {
    name = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}
variable "nlb_domain" {
  type = string
  default = data.kubernetes_service.nginx_ingress_controller.status[0].load_balancer[0].ingress[0].hostname
}
