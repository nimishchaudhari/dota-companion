variable "domain_name" {
  description = "The domain name for the Dota Companion application"
  type        = string
}

variable "app_lb_ip" {
  description = "The IP address of the application load balancer"
  type        = string
}

variable "api_lb_ip" {
  description = "The IP address of the API load balancer"
  type        = string
}

variable "grafana_lb_ip" {
  description = "The IP address of the Grafana load balancer"
  type        = string
}

variable "argocd_lb_ip" {
  description = "The IP address of the Argo CD load balancer"
  type        = string
}
