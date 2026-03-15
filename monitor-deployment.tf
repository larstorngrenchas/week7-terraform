# Monitor App as module
module "monitor" {
  source = "./modules/k8s-app"

  name      = "team-monitor"
  namespace = "fridhemfighters"
  image     = "gcr.io/chas-devsecops-2026/team-monitor:v1"
  port      = 8080 # Eller den port appen lyssnar på internt
  replicas  = 1

  # Resources (Monitor using less resources)
  cpu_request    = "50m"
  memory_request = "64Mi"
  cpu_limit      = "100m"
  memory_limit   = "128Mi"

  # Activating the specific exec-probe!
  health_exec_command = ["node", "-e", "console.log('healthy')"]

  # Other settings
  service_account_name = "monitor-sa"
  image_pull_secrets = ["gcr-secret"]
  config_map_refs    = [kubernetes_config_map.monitor_config.metadata[0].name]

  # Handling of secret variable
  secret_env_vars = {
    "API_KEY" = {
      secret_name = kubernetes_secret.monitor_secret.metadata[0].name
      secret_key  = "API_KEY"
    }
  }

  # Since monitor runs an 'exec'-probe, 
  # we leave health_path as null (disabled).
  health_path = null 
}


#resource "kubernetes_deployment" "team_monitor" {
#  metadata {
#    name      = "team-monitor"
#    namespace = "fridhemfighters"
#    labels = {
#      app = "team-monitor"
#    }
#  }
#
#  spec {
#    replicas = 1
#
#    selector {
#     match_labels = {
#        app = "team-monitor"
#      }
#    }
#
#    template {
#      metadata {
#        labels = {
#          app = "team-monitor"
#        }
#      }
#
#      spec {
#        # Kopplar till ditt ServiceAccount för rättigheter
#        service_account_name = "monitor-sa"
#
#        image_pull_secrets {
#          name = "gcr-secret"
#        }
#
#        container {
#          name              = "monitor"
#          image             = "gcr.io/chas-devsecops-2026/team-monitor:v1"
#          image_pull_policy = "Always"
#
#          # Läser in TEAM_NAME, API_ENDPOINT och CHECK_INTERVAL
#          env_from {
#            config_map_ref {
#              name = "monitor-config"
#            }
#          }
#
#          # Läser in API_KEY specifikt från din Secret
#          env {
#            name = "API_KEY"
#            value_from {
#              secret_key_ref {
#                name = "monitor-secret"
#                key  = "API_KEY"
#              }
#            }
#          }
#
#          resources {
#            requests = {
#              cpu    = "50m"
#              memory = "64Mi"
#            }
#            limits = {
#              cpu    = "100m"
#              memory = "128Mi"
#            }
#          }
#
#         # Hälso-check via exec-kommando
#         liveness_probe {
#            exec {
#              command = ["node", "-e", "console.log('healthy')"]
#            }
#            initial_delay_seconds = 10
#            period_seconds        = 30
#          }
#        }
#      }
#    }
#  }
#}
