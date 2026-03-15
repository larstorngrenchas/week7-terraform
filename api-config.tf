# api-config.tf — API-config deployment and service

resource "kubernetes_config_map" "api_config" {
  metadata {
    name      = "api-config"
    namespace = "fridhemfighters"
    labels = {
      app = "api"
    }
  }

  data = {
    "TEAM_NAME"  = "fridhemfighters"
    "NAMESPACE"  = "fridhemfighters"
    "REDIS_HOST" = "redis-service"
    "REDIS_PORT" = "6379"
    "PORT"       = "3000"
  }
}
