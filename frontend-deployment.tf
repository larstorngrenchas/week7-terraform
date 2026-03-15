# Frontend as module
module "frontend" {
  source = "./modules/k8s-app"

  name      = "frontend"
  namespace = "fridhemfighters"
  image     = "gcr.io/chas-devsecops-2026/team-dashboard-frontend:v1" # Antaget namn
  port      = 80 # Or 3000 depending on what your container runs
  replicas  = 2

  # By setting this, Ingress is automaticly created
  host = "fridhemfighters.chas.retro87.se"

  # This activates the TLS block and cert-manager annotation
  tls_enabled = true

  # Om frontend har en hälso-check endpoint
  health_path = "/" 

  image_pull_secrets = ["gcr-secret"]

  labels = {
    tier = "frontend"
  }

  # Om du behöver skicka med API-url till frontenden via miljövariabel
  #env_vars = {
  #  "API_URL" = "http://api-service.fridhemfighters.svc.cluster.local:3000"
  #}
}

# Frontend Deployment
#resource "kubernetes_deployment" "frontend" {
#  metadata {
#    name      = "frontend"
#    namespace = "fridhemfighters"
#    labels = {
#      app  = "frontend"
#      tier = "frontend"
#    }
#  }
#
#  spec {
#    replicas = 2
#
#    selector {
#      match_labels = {
#        app = "frontend"
#      }
#    }
#
#    template {
#      metadata {
#        labels = {
#          app  = "frontend"
#          tier = "frontend"
#        }
#      }
#
#      spec {
#        image_pull_secrets {
#          name = "gcr-secret"
#        }
#
#        container {
#          name              = "frontend"
#          image             = "gcr.io/chas-devsecops-2026/team-dashboard-frontend:v1"
#          image_pull_policy = "Always"
#
#          port {
#            container_port = 80
#            name           = "http"
#          }
#
#          resources {
#            requests = {
#              cpu    = "100m"
#              memory = "128Mi"
#            }
#            limits = {
#              cpu    = "200m"
#              memory = "256Mi"
#            }
#          }
#
#          liveness_probe {
#           http_get {
#              path = "/"
#              port = "80"
#            }
#            initial_delay_seconds = 5
#            period_seconds        = 10
#          }
#
#          readiness_probe {
#            http_get {
#              path = "/"
#              port = "80"
#            }
#            initial_delay_seconds = 5
#            period_seconds        = 5
#          }
#        }
#      }
#    }
#  }
#}
#
## Frontend Service
#resource "kubernetes_service" "frontend_service" {
#  metadata {
#    name      = "frontend-service"
#    namespace = "fridhemfighters"
#    labels = {
#      app = "frontend"
#    }
#  }
#
#  spec {
#    type = "ClusterIP"
#    selector = {
#      app = "frontend"
#    }
#
#    port {
#      port        = 80
#      target_port = 80
#      protocol    = "TCP"
#      name        = "http"
#    }
#  }
#}
