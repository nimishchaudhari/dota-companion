variable "namespace" {
  description = "Namespace for the sealed-secrets controller"
  type        = string
  default     = "kube-system"
}

variable "chart_version" {
  description = "Version of the sealed-secrets Helm chart"
  type        = string
  default     = "2.9.0"
}
