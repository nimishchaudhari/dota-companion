resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network
  subnetwork = var.subnetwork

  ip_allocation_policy {
    cluster_secondary_range_name  = var.ip_range_pods
    services_secondary_range_name = var.ip_range_services
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # Enable Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Enable Network Policy
  network_policy {
    enabled = true
  }

  # Enable Dataplane V2
  datapath_provider = "ADVANCED_DATAPATH"
}

resource "google_container_node_pool" "pools" {
  for_each = { for np in var.node_pools : np.name => np }

  name       = each.value.name
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = lookup(each.value, "initial_node_count", 1)

  autoscaling {
    min_node_count = lookup(each.value, "min_count", 1)
    max_node_count = lookup(each.value, "max_count", 3)
  }

  management {
    auto_repair  = lookup(each.value, "auto_repair", true)
    auto_upgrade = lookup(each.value, "auto_upgrade", true)
  }

  node_config {
    preemptible  = lookup(each.value, "preemptible", false)
    machine_type = lookup(each.value, "machine_type", "e2-standard-2")
    disk_size_gb = lookup(each.value, "disk_size_gb", 100)
    disk_type    = lookup(each.value, "disk_type", "pd-standard")
    image_type   = lookup(each.value, "image_type", "COS_CONTAINERD")

    # Google recommended metadata
    metadata = {
      disable-legacy-endpoints = "true"
    }

    # Apply the given metadata to the nodes
    dynamic "metadata" {
      for_each = lookup(var.node_pools_metadata, "all", {})
      content {
        key   = metadata.key
        value = metadata.value
      }
    }

    dynamic "metadata" {
      for_each = lookup(var.node_pools_metadata, each.value.name, {})
      content {
        key   = metadata.key
        value = metadata.value
      }
    }

    # Apply the given labels to the nodes
    dynamic "labels" {
      for_each = lookup(var.node_pools_labels, "all", {})
      content {
        key   = labels.key
        value = labels.value
      }
    }

    dynamic "labels" {
      for_each = lookup(var.node_pools_labels, each.value.name, {})
      content {
        key   = labels.key
        value = labels.value
      }
    }

    # Apply the given taints to the nodes
    dynamic "taint" {
      for_each = lookup(var.node_pools_taints, "all", [])
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    dynamic "taint" {
      for_each = lookup(var.node_pools_taints, each.value.name, [])
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    # Apply the given tags to the nodes
    tags = concat(
      lookup(var.node_pools_tags, "all", []),
      lookup(var.node_pools_tags, each.value.name, [])
    )

    # Apply the given service account and scopes to the nodes
    service_account = google_service_account.gke_sa.email
    oauth_scopes = concat(
      lookup(var.node_pools_oauth_scopes, "all", []),
      lookup(var.node_pools_oauth_scopes, each.value.name, [])
    )

    # Enable Workload Identity on the node pool
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}

# Create a service account for the GKE nodes
resource "google_service_account" "gke_sa" {
  account_id   = "gke-nodes-sa"
  display_name = "GKE Nodes Service Account"
}

# Grant the service account the required roles
resource "google_project_iam_member" "gke_sa_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/storage.objectViewer",
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}
