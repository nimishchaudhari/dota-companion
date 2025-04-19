output "prometheus_server_endpoint" {
  description = "The endpoint of the Prometheus server"
  value       = "http://prometheus-operated.${var.monitoring_namespace}.svc.cluster.local:9090"
}

output "grafana_endpoint" {
  description = "The endpoint of the Grafana server"
  value       = "http://prometheus-grafana.${var.monitoring_namespace}.svc.cluster.local:80"
}

output "grafana_admin_password" {
  description = "The admin password for Grafana"
  value       = "prom-operator"
  sensitive   = true
}

output "loki_endpoint" {
  description = "The endpoint of the Loki server"
  value       = "http://loki.${var.monitoring_namespace}.svc.cluster.local:3100"
}

output "alertmanager_endpoint" {
  description = "The endpoint of the Alertmanager server"
  value       = "http://alertmanager-operated.${var.monitoring_namespace}.svc.cluster.local:9093"
}
