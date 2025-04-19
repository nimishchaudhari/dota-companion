resource "google_sql_database_instance" "postgres" {
  name             = var.instance_name
  database_version = "POSTGRES_16"
  region           = var.region
  project          = var.project_id

  settings {
    tier              = var.tier
    availability_type = var.availability_type
    disk_size         = var.disk_size
    disk_type         = var.disk_type
    
    backup_configuration {
      enabled                        = true
      start_time                     = "01:00"
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7
      backup_retention_settings {
        retained_backups = 14
        retention_unit   = "COUNT"
      }
    }

    maintenance_window {
      day          = 1  # Monday
      hour         = 2  # 2 AM
      update_track = "stable"
    }

    database_flags {
      name  = "max_connections"
      value = "500"
    }

    database_flags {
      name  = "shared_buffers"
      value = "256MB"
    }

    ip_configuration {
      ipv4_enabled    = true
      private_network = var.network_id
      require_ssl     = true
    }

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 4096
      record_application_tags = true
      record_client_address   = false
    }
  }

  deletion_protection = var.deletion_protection
}

# Create the main database
resource "google_sql_database" "main" {
  name     = var.database_name
  instance = google_sql_database_instance.postgres.name
  charset  = "UTF8"
  collation = "en_US.UTF8"
}

# Create the database user
resource "google_sql_user" "main" {
  name     = var.database_user
  instance = google_sql_database_instance.postgres.name
  password = var.database_password
}

# Set up TimescaleDB extension if enabled
resource "null_resource" "setup_timescaledb" {
  count = var.enable_timescale ? 1 : 0

  triggers = {
    instance_id = google_sql_database_instance.postgres.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      gcloud sql connect ${google_sql_database_instance.postgres.name} --user=${var.database_user} --quiet --project=${var.project_id} <<< "CREATE EXTENSION IF NOT EXISTS timescaledb;"
    EOT
  }

  depends_on = [
    google_sql_database.main,
    google_sql_user.main
  ]
}
