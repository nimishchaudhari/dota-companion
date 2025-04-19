resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.monitoring_namespace
  }
}

# Install Prometheus Operator
resource "helm_release" "prometheus_operator" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.prometheus_chart_version
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    templatefile("${path.module}/templates/prometheus-values.yaml", {
      prometheus_retention = var.prometheus_retention
      prometheus_storage   = var.prometheus_storage
      grafana_storage      = var.grafana_storage
      pagerduty_service_key = var.pagerduty_service_key
    })
  ]

  depends_on = [kubernetes_namespace.monitoring]
}

# Install Loki
resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  version    = var.loki_chart_version
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    templatefile("${path.module}/templates/loki-values.yaml", {
      loki_storage = var.loki_storage
    })
  ]

  depends_on = [kubernetes_namespace.monitoring]
}

# Create Grafana dashboards as ConfigMaps
resource "kubernetes_config_map" "grafana_dashboards" {
  metadata {
    name      = "dota-companion-dashboards"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "dota-companion-overview.json" = file("${path.module}/dashboards/overview-dashboard.json")
    "dota-companion-api.json"      = file("${path.module}/dashboards/api-dashboard.json")
    "dota-companion-llm.json"      = file("${path.module}/dashboards/llm-dashboard.json")
    "dota-companion-websocket.json" = file("${path.module}/dashboards/websocket-dashboard.json")
  }

  depends_on = [helm_release.prometheus_operator]
}

# Create PagerDuty integration for alerting
resource "kubernetes_secret" "pagerduty_secret" {
  metadata {
    name      = "pagerduty-secret"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    serviceKey = var.pagerduty_service_key
  }

  depends_on = [kubernetes_namespace.monitoring]
}

# Create AlertManager configuration for routing alerts
resource "kubernetes_config_map" "alertmanager_config" {
  metadata {
    name      = "alertmanager-config"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      alertmanager_config = "true"
    }
  }

  data = {
    "alertmanager.yaml" = templatefile("${path.module}/templates/alertmanager.yaml", {
      pagerduty_service_key = var.pagerduty_service_key
    })
  }

  depends_on = [helm_release.prometheus_operator]
}
