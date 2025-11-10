resource "helm_release" "external_nginx" {
  name = "external"

  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress"
  create_namespace = true
  version          = var.nginx_ingress_helm_verion

  values = [file("${path.module}/files/nginx-ingress.yaml")]

  depends_on = [helm_release.aws_lbc]
}