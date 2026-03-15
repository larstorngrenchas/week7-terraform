# redis.tf — Redis deployment and service

# --- Redis ---
module "redis" {
  source    = "./modules/k8s-app"
  name      = "redis"
  namespace = var.namespace
  image     = var.redis_image
  port      = 6379

  cpu_request    = "100m"
  memory_request = "128Mi"
  cpu_limit      = "200m"
  memory_limit   = "256Mi"
}



#resource "kubernetes_deployment" "redis" {
#  metadata {
#    name      = "redis"
#    namespace = var.namespace
#
#    labels = {
#      app        = "redis"
#      managed-by = "terraform"
#    }
#  }

#  spec {
#    replicas = 1
#
#    selector {
#     match_labels = {
#       app = "redis"
#     }
#   }

#    template {
#      metadata {
#        labels = {
#          app = "redis"
#        }
#      }

#      spec {
#        container {
#          name  = "redis"
#          image = "redis:7-alpine"
#
#          port {
#            container_port = 6379
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
#        }
#      }
#    }
#  }
#}

#resource "kubernetes_service" "redis" {
#  metadata {
#    name      = "redis-service"
#    namespace = "fridhemfighters"
#
#
#  spec {
#    selector = {
#      app = "redis"
#    }
#
#    port {
#      port        = 6379
#     target_port = 6379
#    }
#  }
#}