output "instance_name" {
  description = "The name of the CloudSQL instance"
  value       = google_sql_database_instance.postgres.name
}

output "instance_connection_name" {
  description = "The connection name of the CloudSQL instance"
  value       = google_sql_database_instance.postgres.connection_name
}

output "database_name" {
  description = "The name of the database"
  value       = google_sql_database.main.name
}

output "database_user" {
  description = "The name of the database user"
  value       = google_sql_user.main.name
}

output "public_ip_address" {
  description = "The public IP address of the CloudSQL instance"
  value       = google_sql_database_instance.postgres.public_ip_address
}
