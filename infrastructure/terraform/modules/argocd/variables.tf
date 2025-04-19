variable "kubernetes_cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "argocd_namespace" {
  description = "The namespace to deploy Argo CD"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "The version of the Argo CD Helm chart"
  type        = string
  default     = "5.51.0"
}

variable "applicationset_chart_version" {
  description = "The version of the ApplicationSet Helm chart"
  type        = string
  default     = "1.12.1"
}

variable "argocd_admin_password_bcrypt" {
  description = "The bcrypt hash of the Argo CD admin password"
  type        = string
  default     = "$2a$10$5xe8ztcmY9eizJOMGfZQDOgQzPXr7pI6JzMJCC9HBUNSUc0TzQdRC" # Default password is 'admin'
  sensitive   = true
}

variable "git_username" {
  description = "The username for Git repositories"
  type        = string
  default     = ""
  sensitive   = true
}

variable "git_password" {
  description = "The password or token for Git repositories"
  type        = string
  default     = ""
  sensitive   = true
}

variable "repos" {
  description = "List of Git repositories for Argo CD to sync"
  type        = list(object({
    url       = string
    name      = string
    path      = string
    namespace = string
  }))
  default     = []
}
