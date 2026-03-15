# variables.tf — team-specific configuration

variable "namespace" {
  description = "Your team's Kubernetes namespace"
  type        = string
}

variable "team_name" {
  description = "Your team's display name"
  type        = string
}

variable "monitor_api_key" {
  description = "API-nyckeln för Team Flags"
  type        = string
  sensitive   = true  # Detta gör att värdet döljs i loggarna
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}

variable "redis_image" {
  description = "Redis container image"
  type        = string
  default     = "redis:7-alpine"
}

variable "api_image" {
  description = "API backend container image"
  type        = string
  default     = "retro87/team-api:latest"
}

variable "frontend_image" {
  description = "Frontend container image"
  type        = string
  default     = "retro87/team-frontend:latest"
}

variable "api_replicas" {
  description = "Number of API replicas"
  type        = number
  default     = 1

  validation {
    condition     = var.api_replicas >= 1 && var.api_replicas <= 3
    error_message = "Replicas must be between 1 and 3 (namespace quota limit)."
  }
}