output "host" {
  description = "The IP address of the Redis instance"
  value       = google_redis_instance.cache.host
}

output "port" {
  description = "The port of the Redis instance"
  value       = google_redis_instance.cache.port
}

output "id" {
  description = "The ID of the Redis instance"
  value       = google_redis_instance.cache.id
}

output "current_location_id" {
  description = "The current zone of the Redis instance"
  value       = google_redis_instance.cache.current_location_id
}

output "auth_string" {
  description = "The AUTH string for authenticating with the Redis instance"
  value       = google_redis_instance.cache.auth_string
  sensitive   = true
}
