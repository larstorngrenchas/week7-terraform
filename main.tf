terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
  }
    # Store state in Google Cloud Storage
  backend "gcs" {
    bucket = "chas-tf-state-fridhemfighters"   # Your team's bucket from table above
    prefix = "terraform/state/lars"  # YOUR name! e.g. "terraform/state/daniel"
  }
}

# Use your existing kubeconfig — the same one from Week 6
provider "kubernetes" {
  config_path = "/Users/lasse/Documents/YH/GitHubRepo/week7-terraform/fridhemfighters-kubeconfig.yaml"
  # Or if you use KUBECONFIG env var, Terraform picks it up automatically
}
# Create a ConfigMap in your team namespace
resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "terraform-demo"
    namespace = "fridhemfighters"  # Replace: girly-pops, m4k-gang, etc.

    labels = {
      "managed-by" = "terraform"
      "team"       = "fridhemfighters"
    }
  }

  data = {
    APP_ENV     = "production"
    APP_VERSION = "1.0.1"
    MANAGED_BY  = "terraform"
  }
  
}
