#resource "kubernetes_ingress_v1" "team_dashboard" {
#  metadata {
#    name      = "team-dashboard"
#    namespace = "fridhemfighters"
#    labels = {
#      app = "team-dashboard"
#    }
#    annotations = {
#      "kubernetes.io/ingress.class" = "nginx"
#    }
#  }
#
#  spec {
#    rule {
#      host = "fridhemfighters.chas.retro87.se"
#      http {
#        path {
#          path      = "/"
#          path_type = "Prefix"
#         backend {
#            service {
#              name = "frontend-service"
#              port {
#                number = 80
#              }
#            }
#          }
#        }
#      }
#    }
#  }
#}
