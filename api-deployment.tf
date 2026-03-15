# api-deployment.tf — API deployment and service

module "api" {
  source = "./modules/k8s-app"

  name      = "api"
  namespace = "fridhemfighters"
  image     = "gcr.io/chas-devsecops-2026/team-dashboard-api:v1"
  port      = 3000
  replicas  = 2

  # Resursgränser
  cpu_limit    = "200m"
  memory_limit = "256Mi"

  # Behövs bara om appen har en annan path än /health
  health_path        = "/health" 

  # Nya variabler för att matcha den gamla koden
  image_pull_secrets = ["gcr-secret"]
  config_map_refs    = [kubernetes_config_map.api_config.metadata[0].name]
  
  labels = {
    tier = "backend"
  }
}


# API Deployment
#resource "kubernetes_deployment" "api" {
#  metadata {
#    name      = "api"
#    namespace = "fridhemfighters"
#    labels = {
#      app  = "api"
#      tier = "backend"
#    }
#  }
#
#  spec {
#    replicas = 2
#
#    selector {
#      match_labels = {
#        app = "api"
#      }
#    }
#
#    template {
#      metadata {
#        labels = {
#          app  = "api"
#          tier = "backend"
#        }
#      }
#
#      spec {
#        image_pull_secrets {
#          name = "gcr-secret"
#        }
#
#        container {
#          name              = "api"
#          image             = "gcr.io/chas-devsecops-2026/team-dashboard-api:v1"
#          image_pull_policy = "Always"
#
#          port {
#            container_port = 3000
#            name           = "http"
#          }
#
#          env_from {
#            config_map_ref {
#              name = "api-config"
#            }
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
#            http_get {
#              path = "/health"
#              port = "3000"
#            }
#            initial_delay_seconds = 10
#            period_seconds        = 10
#          }
#
#         readiness_probe {
#            http_get {
#              path = "/health"
#              port = "3000"
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
# API Service
#resource "kubernetes_service" "api_service" {
#  metadata {
#    name      = "api-service"
#    namespace = "fridhemfighters"
#    labels = {
#      app = "api"
#    }
#  }
#
#  spec {
#    type = "ClusterIP"
#    selector = {
#      app = "api"
#    }
#
#    port {
#      port        = 3000
#      target_port = 3000
#      protocol    = "TCP"
#      name        = "http"
#    }
#  }
#}
