# Monitor Configuration ConfigMap
resource "kubernetes_config_map" "monitor_config" {
  metadata {
    name      = "monitor-config"
    namespace = "fridhemfighters"
    labels = {
      app = "team-monitor"
    }
  }

  data = {
    "TEAM_NAME"      = "fridhemfighters"
    "API_ENDPOINT"   = "https://chas-academy-devops-2026-aqm38z7fe-erkan-djafers-projects.vercel.app/api/team-status"
    "CHECK_INTERVAL" = "30000"
  }
}
