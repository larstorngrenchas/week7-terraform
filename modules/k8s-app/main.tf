# modules/k8s-app/main.tf — Reusable app deployment module

variable "name" {
  description = "Application name"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "image" {
  description = "Container image"
  type        = string
}

variable "port" {
  description = "Container port"
  type        = number
}

variable "replicas" {
  description = "Number of replicas"
  type        = number
  default     = 1
}

variable "cpu_request" {
  type    = string
  default = "100m"
}

variable "memory_request" {
  type    = string
  default = "128Mi"
}

variable "cpu_limit" {
  type    = string
  default = "500m"
}

variable "memory_limit" {
  type    = string
  default = "512Mi"
}

variable "env_vars" {
  description = "Environment variables for the container"
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Additional labels"
  type        = map(string)
  default     = {}
}

variable "image_pull_secrets" {
  type    = list(string)
  default = []
}

variable "config_map_refs" {
  type    = list(string)
  default = []
}
# Updates for health_path, liveness_dealy and rediness_delay
variable "health_path" {
  description = "Path for liveness/readiness probes. Set to null to disable probes."
  type        = string
  #default     = "/health"
  default     = null # disabled as default 
}
variable "liveness_delay" {
  type    = number
  default = 10
}
variable "readiness_delay" {
  type    = number
  default = 5
}

# Updates for monitor
variable "service_account_name" {
  type    = string
  default = null
}
variable "secret_env_vars" {
  description = "Map of env var name to secret details"
  type = map(object({
    secret_name = string
    secret_key  = string
  }))
  default = {}
}
variable "health_exec_command" {
  description = "Command for exec probes. Set to a list of strings, e.g. ['node', '-e', '...']"
  type        = list(string)
  default     = null
}

# Update for ingress
variable "host" {
  description = "The DNS host name for Ingress. Set to null to disable Ingress."
  type        = string
  default     = null
}
variable "tls_enabled" {
  description = "Enable TLS/HTTPS for the Ingress"
  type        = bool
  default     = false
}

# --- Resources ---

resource "kubernetes_deployment" "app" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = merge({
      app        = var.name
      managed-by = "terraform"
    }, var.labels)
  }

  spec {
    replicas = var.replicas
    selector {
      match_labels = { app = var.name }
    }
    template {
      metadata {
        labels = merge({ app = var.name }, var.labels)
      }
      spec {
        dynamic "image_pull_secrets" {
          for_each = var.image_pull_secrets
          content {
            name = image_pull_secrets.value
          }
        }
        service_account_name = var.service_account_name

        container {
          name  = var.name
          image = var.image

          #liveness_probe {
          #  http_get {
          #    path = var.health_path
          #    port = var.port
          #  }
          #  initial_delay_seconds = var.liveness_delay
          #  period_seconds        = 10
          #}
          #dynamic "liveness_probe" {
          #  for_each = var.health_path != null ? [1] : []
          #  content {
          #    http_get {
          #      path = var.health_path
          #      port = var.port
          #    }
          #    initial_delay_seconds = var.liveness_delay
          #    period_seconds        = 10
          #  }
          #}
          dynamic "liveness_probe" {
            # Kör om antingen health_path ELLER health_exec_command är satt
            for_each = (var.health_path != null || var.health_exec_command != null) ? [1] : []
            content {
              initial_delay_seconds = var.liveness_delay
              period_seconds        = 30 # Vi ökar denna något för monitor-behov

              # Om health_path finns -> kör http_get
              dynamic "http_get" {
                for_each = var.health_path != null ? [1] : []
                content {
                  path = var.health_path
                  port = var.port
                }
              }

              # Om health_exec_command finns -> kör exec
              dynamic "exec" {
                for_each = var.health_exec_command != null ? [1] : []
                content {
                  command = var.health_exec_command
                }
              }
            }
          }

          #readiness_probe {
          #  http_get {
          #    path = var.health_path
          #   port = var.port
          #  }
          #  initial_delay_seconds = var.readiness_delay
          #  period_seconds        = 5
          #}
          #dynamic "readiness_probe" {
          #  for_each = var.health_path != null ? [1] : []
          #  content {
          #    http_get {
          #      path = var.health_path
          #      port = var.port
          #    }
          #    initial_delay_seconds = var.readiness_delay
          #    period_seconds        = 5
          #  }
          #}
          dynamic "readiness_probe" {
            # Runs if either health_path OR health_exec_command is set
            for_each = (var.health_path != null || var.health_exec_command != null) ? [1] : []
            content {
              initial_delay_seconds = var.readiness_delay
              period_seconds        = 30 # Vi ökar denna något för monitor-behov

              # If health_path exists -> run http_get
              dynamic "http_get" {
                for_each = var.health_path != null ? [1] : []
                content {
                  path = var.health_path
                  port = var.port
                }
              }

              # If health_exec_command exists -> run exec
              dynamic "exec" {
                for_each = var.health_exec_command != null ? [1] : []
                content {
                  command = var.health_exec_command
                }
              }
            }
          }

          port {
            container_port = var.port
          }
          resources {
            requests = {
              cpu    = var.cpu_request
              memory = var.memory_request
            }
            limits = {
              cpu    = var.cpu_limit
              memory = var.memory_limit
            }
          }
          dynamic "env" {
            for_each = var.env_vars
            content {
              name  = env.key
              value = env.value
            }
          }
          # For monitor
          dynamic "env" {
            for_each = var.secret_env_vars
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name = env.value.secret_name
                  key  = env.value.secret_key
                }
              }
            }
          }

          dynamic "env_from" {
            for_each = var.config_map_refs
            content {
              config_map_ref {
                name = env_from.value
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name      = "${var.name}-service"
    namespace = var.namespace
  }
  spec {
    selector = { app = var.name }
    port {
      port        = var.port
      target_port = var.port
    }
  }
}

resource "kubernetes_ingress_v1" "team_dashboard" {
  # Only create the Ingress resource if variable 'host' is set
  count = var.host != null ? 1 : 0

  metadata {
    name      = "team-dashboard"
    namespace = var.namespace
    labels = {
      app = "team-dashboard"
    }
    annotations = merge(
      { "kubernetes.io/ingress.class" = "nginx" },
      # If TLS is ON, add annotation for cert-manager
      var.tls_enabled ? { "cert-manager.io/cluster-issuer" = "letsencrypt-prod" } : {}
    )
  }

  spec {
    rule {
      host = var.host
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.app.metadata[0].name
              port {
                number = var.port
              }
            }
          }
        }
      }
    }
    # TLS block is only created if tls_enabled is true
    dynamic "tls" {
      for_each = var.tls_enabled ? [1] : []
      content {
        hosts       = [var.host]
        secret_name = "${var.name}-tls-cert" # Namnet på secret där certifikatet sparas
      }
    }
  }
}

# --- Outputs ---

output "deployment_name" {
  value = kubernetes_deployment.app.metadata[0].name
}

output "service_name" {
  value = kubernetes_service.app.metadata[0].name
}

output "service_dns" {
  value = "${kubernetes_service.app.metadata[0].name}.${var.namespace}.svc.cluster.local"
}

