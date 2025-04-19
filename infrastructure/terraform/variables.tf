variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "The GCP zone to deploy resources"
  type        = string
  default     = "europe-west1-b"
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "dota-companion-cluster"
}

variable "network" {
  description = "The VPC network to host the cluster"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "The subnetwork to host the cluster"
  type        = string
  default     = "default"
}

variable "ip_range_pods" {
  description = "The secondary IP range name for pods"
  type        = string
  default     = "ip-range-pods"
}

variable "ip_range_services" {
  description = "The secondary IP range name for services"
  type        = string
  default     = "ip-range-services"
}

variable "node_pools" {
  description = "List of node pools"
  type        = list(map(string))
  default = [
    {
      name               = "default-node-pool"
      machine_type       = "e2-standard-2"
      node_locations     = "europe-west1-b,europe-west1-c"
      min_count          = 1
      max_count          = 5
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      auto_repair        = true
      auto_upgrade       = true
      preemptible        = false
      initial_node_count = 3
    }
  ]
}

variable "node_pools_oauth_scopes" {
  description = "OAuth scopes for node pools"
  type        = map(list(string))
  default = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]
    default-node-pool = []
  }
}

variable "node_pools_labels" {
  description = "Labels for node pools"
  type        = map(map(string))
  default = {
    all = {}
    default-node-pool = {
      default-node-pool = true
    }
  }
}

variable "node_pools_metadata" {
  description = "Metadata for node pools"
  type        = map(map(string))
  default = {
    all = {}
    default-node-pool = {
      node-pool-metadata-custom-value = "default-node-pool"
    }
  }
}

variable "node_pools_taints" {
  description = "Taints for node pools"
  type        = map(list(object({ key = string, value = string, effect = string })))
  default = {
    all = []
    default-node-pool = []
  }
}

variable "node_pools_tags" {
  description = "Network tags for node pools"
  type        = map(list(string))
  default = {
    all = []
    default-node-pool = [
      "default-node-pool",
    ]
  }
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "argocd_repos" {
  description = "List of Git repositories for Argo CD to sync"
  type        = list(object({
    url       = string
    name      = string
    path      = string
    namespace = string
  }))
  default     = []
}

variable "pagerduty_service_key" {
  description = "PagerDuty service key for alerts"
  type        = string
  sensitive   = true
}
