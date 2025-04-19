output "zone_id" {
  description = "The Cloudflare Zone ID"
  value       = cloudflare_zone.dota_companion_zone.id
}

output "app_hostname" {
  description = "The app hostname"
  value       = "app.${var.domain_name}"
}

output "api_hostname" {
  description = "The API hostname"
  value       = "api.${var.domain_name}"
}

output "grafana_hostname" {
  description = "The Grafana hostname"
  value       = "grafana.${var.domain_name}"
}

output "argocd_hostname" {
  description = "The Argo CD hostname"
  value       = "argocd.${var.domain_name}"
}
