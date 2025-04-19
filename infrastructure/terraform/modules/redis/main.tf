resource "google_redis_instance" "cache" {
  name           = var.instance_name
  tier           = var.tier
  memory_size_gb = var.memory_size_gb
  region         = var.region
  project        = var.project_id
  
  location_id             = var.zone
  alternative_location_id = var.alternative_zone
  
  authorized_network = var.network_id
  connect_mode       = "PRIVATE_SERVICE_ACCESS"
  
  redis_version     = var.redis_version
  redis_configs     = var.redis_configs
  display_name      = "Dota Companion Redis Cache"
  
  maintenance_policy {
    weekly_maintenance_window {
      day = "SUNDAY"
      start_time {
        hours   = 2
        minutes = 0
      }
    }
  }
  
  labels = {
    environment = var.environment
    application = "dota-companion"
  }
  
  auth_enabled = true
  
  transit_encryption_mode = "SERVER_AUTHENTICATION"
}
