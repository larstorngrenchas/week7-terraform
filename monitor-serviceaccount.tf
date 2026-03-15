# Service Account för Monitor
resource "kubernetes_service_account" "monitor_sa" {
  metadata {
    name      = "monitor-sa"
    namespace = "fridhemfighters"
    labels = {
      app = "team-monitor"
    }
  }
}

# Role: Definierar rättigheter
resource "kubernetes_role" "monitor_role" {
  metadata {
    name      = "monitor-role"
    namespace = "fridhemfighters"
  }

  # Tillåt läsning av pods och services
  rule {
    api_groups = [""]
    resources  = ["pods", "services"]
    verbs      = ["get", "list", "watch"]
  }

  # Tillåt läsning av deployments
  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets"]
    verbs      = ["get", "list", "watch"]
  }

  # Tillåt läsning av ingress
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
}

# RoleBinding: Kopplar samman SA och Role
resource "kubernetes_role_binding" "monitor_binding" {
  metadata {
    name      = "monitor-binding"
    namespace = "fridhemfighters"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.monitor_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.monitor_sa.metadata[0].name
    namespace = "fridhemfighters"
  }
}
