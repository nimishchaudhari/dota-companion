output "controller_name" {
  description = "The name of the sealed-secrets controller"
  value       = "sealed-secrets-controller"
}

output "controller_namespace" {
  description = "The namespace of the sealed-secrets controller"
  value       = kubernetes_namespace.sealed_secrets.metadata[0].name
}

output "api_keys_template_path" {
  description = "Path to the API keys template"
  value       = local_file.api_keys_template.filename
}

output "jwt_secret_template_path" {
  description = "Path to the JWT secret template"
  value       = local_file.jwt_secret_template.filename
}

output "db_credentials_template_path" {
  description = "Path to the database credentials template"
  value       = local_file.db_credentials_template.filename
}

output "tls_certificates_template_path" {
  description = "Path to the TLS certificates template"
  value       = local_file.tls_certificates_template.filename
}
