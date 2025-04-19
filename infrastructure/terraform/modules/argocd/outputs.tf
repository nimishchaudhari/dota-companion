output "argocd_server_service_name" {
  description = "The name of the Argo CD server service"
  value       = "argocd-server"
}

output "argocd_namespace" {
  description = "The namespace where Argo CD is deployed"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_server_url" {
  description = "The URL for accessing the Argo CD server"
  value       = "https://argocd.dota-companion.example.com"
}
