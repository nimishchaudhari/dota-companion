variable "kubernetes_cluster" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "monitoring_namespace" {
  description = "The namespace to deploy monitoring resources"
  type        = string
  default     = "monitoring"
}

variable "prometheus_chart_version" {
  description = "The version of the Prometheus Operator Helm chart"
  type        = string
  default     = "51.2.0"
}

variable "loki_chart_version" {
  description = "The version of the Loki Stack Helm chart"
  type        = string
  default     = "2.9.9"
}

variable "prometheus_retention" {
  description = "The retention period for Prometheus data"
  type        = string
  default     = "15d"
}

variable "prometheus_storage" {
  description = "The storage size for Prometheus"
  type        = string
  default     = "50Gi"
}

variable "grafana_storage" {
  description = "The storage size for Grafana"
  type        = string
  default     = "10Gi"
}

variable "loki_storage" {
  description = "The storage size for Loki"
  type        = string
  default     = "50Gi"
}

variable "pagerduty_service_key" {
  description = "The PagerDuty service key for alerts"
  type        = string
  sensitive   = true
}
