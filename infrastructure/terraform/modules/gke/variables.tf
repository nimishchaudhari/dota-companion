variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
}

variable "zone" {
  description = "The GCP zone to deploy resources"
  type        = string
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "network" {
  description = "The VPC network to host the cluster"
  type        = string
}

variable "subnetwork" {
  description = "The subnetwork to host the cluster"
  type        = string
}

variable "ip_range_pods" {
  description = "The secondary IP range name for pods"
  type        = string
}

variable "ip_range_services" {
  description = "The secondary IP range name for services"
  type        = string
}

variable "node_pools" {
  description = "List of node pools"
  type        = list(map(string))
}

variable "node_pools_oauth_scopes" {
  description = "OAuth scopes for node pools"
  type        = map(list(string))
}

variable "node_pools_labels" {
  description = "Labels for node pools"
  type        = map(map(string))
}

variable "node_pools_metadata" {
  description = "Metadata for node pools"
  type        = map(map(string))
}

variable "node_pools_taints" {
  description = "Taints for node pools"
  type        = map(list(object({ key = string, value = string, effect = string })))
}

variable "node_pools_tags" {
  description = "Network tags for node pools"
  type        = map(list(string))
}
