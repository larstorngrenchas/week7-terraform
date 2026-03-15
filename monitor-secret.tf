resource "kubernetes_secret" "monitor_secret" {
  metadata {
    name      = "monitor-secret"
    namespace = "fridhemfighters"
    labels = {
      app = "team-monitor"
    }
  }

  type = "Opaque"

  # Vi byter string_data mot data och kodar om variabeln
  data = {
    "API_KEY" = base64encode(var.monitor_api_key)
  }
}
