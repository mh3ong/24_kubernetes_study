data "kubernetes_service" "nginx_ingress_controller" {
  metadata {
    name = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}
