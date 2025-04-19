terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
  
  backend "gcs" {
    bucket = "dota-companion-terraform-state"
    prefix = "terraform/state"
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${module.gke.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

data "google_client_config" "default" {}

module "gke" {
  source     = "./modules/gke"
  project_id = var.project_id
  region     = var.region
  zone       = var.zone
  
  # GKE cluster configuration
  cluster_name             = var.cluster_name
  network                  = var.network
  subnetwork               = var.subnetwork
  ip_range_pods            = var.ip_range_pods
  ip_range_services        = var.ip_range_services
  node_pools               = var.node_pools
  node_pools_oauth_scopes  = var.node_pools_oauth_scopes
  node_pools_labels        = var.node_pools_labels
  node_pools_metadata      = var.node_pools_metadata
  node_pools_taints        = var.node_pools_taints
  node_pools_tags          = var.node_pools_tags
}

# Create namespaces for different environments
resource "kubernetes_namespace" "dev" {
  metadata {
    name = "dota-companion-dev"
  }
  
  depends_on = [module.gke]
}

resource "kubernetes_namespace" "staging" {
  metadata {
    name = "dota-companion-staging"
  }
  
  depends_on = [module.gke]
}

resource "kubernetes_namespace" "prod" {
  metadata {
    name = "dota-companion-prod"
  }
  
  depends_on = [module.gke]
}

# Configure Argo CD for GitOps
module "argocd" {
  source                  = "./modules/argocd"
  kubernetes_cluster_name = module.gke.name
  argocd_namespace        = "argocd"
  repos                   = var.argocd_repos
}

# Set up monitoring with Prometheus, Grafana, and Loki
module "monitoring" {
  source             = "./modules/monitoring"
  kubernetes_cluster = module.gke.name
  monitoring_namespace = "monitoring"
  
  # PagerDuty integration
  pagerduty_service_key = var.pagerduty_service_key
  
  depends_on = [module.gke]
}
