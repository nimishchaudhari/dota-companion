resource "kubernetes_namespace" "sealed_secrets" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "sealed_secrets" {
  name       = "sealed-secrets"
  repository = "https://bitnami-labs.github.io/sealed-secrets"
  chart      = "sealed-secrets"
  version    = var.chart_version
  namespace  = kubernetes_namespace.sealed_secrets.metadata[0].name
  
  set {
    name  = "fullnameOverride"
    value = "sealed-secrets-controller"
  }
  
  set {
    name  = "resources.requests.memory"
    value = "128Mi"
  }
  
  set {
    name  = "resources.requests.cpu"
    value = "50m"
  }
  
  set {
    name  = "resources.limits.memory"
    value = "256Mi"
  }
  
  set {
    name  = "resources.limits.cpu"
    value = "100m"
  }

  set {
    name  = "serviceMonitor.enabled"
    value = "true"
  }

  set {
    name  = "serviceMonitor.labels.monitoring"
    value = "prometheus"
  }
}

# Create generic secrets template
resource "local_file" "api_keys_template" {
  content  = <<-EOT
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: api-keys
  namespace: NAMESPACE_PLACEHOLDER
spec:
  encryptedData:
    OPENDOTA_API_KEY: AgBy8hgMjOULBXBnMVBmJEGkWIQKVD... # Replace with actual sealed secret
    STRATZ_API_KEY: AgBy8hh7mJVHQHyUSGdl3M5RY2R... # Replace with actual sealed secret
  template:
    metadata:
      name: api-keys
      namespace: NAMESPACE_PLACEHOLDER
    type: Opaque
EOT
  filename = "${path.module}/templates/api-keys-template.yaml"
}

# Create JWT secret template
resource "local_file" "jwt_secret_template" {
  content  = <<-EOT
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: jwt-secret
  namespace: NAMESPACE_PLACEHOLDER
spec:
  encryptedData:
    JWT_SECRET: AgCXFfsiE9vUG4N6NNmvYrEIv3Qpyq... # Replace with actual sealed secret
    REFRESH_SECRET: AgDpT8vCrPFgdYrH7jFIKl9TLK... # Replace with actual sealed secret
  template:
    metadata:
      name: jwt-secret
      namespace: NAMESPACE_PLACEHOLDER
    type: Opaque
EOT
  filename = "${path.module}/templates/jwt-secret-template.yaml"
}

# Create database credentials template
resource "local_file" "db_credentials_template" {
  content  = <<-EOT
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: db-credentials
  namespace: NAMESPACE_PLACEHOLDER
spec:
  encryptedData:
    POSTGRES_USER: AgB7kH8dJK9qLpMn2rTvFgRm8yU... # Replace with actual sealed secret
    POSTGRES_PASSWORD: AgCmTy6HgP2XnrKjV9MlKrTgF... # Replace with actual sealed secret
    POSTGRES_HOST: AgDeF3xKlP2XJrh9nGdTvYhGLk... # Replace with actual sealed secret
    POSTGRES_DB: AgCvH7jKl2XnPqRtGmNbVzHgTr... # Replace with actual sealed secret
    REDIS_PASSWORD: AgCnT6yHgP3XmrLjV0MkLsTgE... # Replace with actual sealed secret
    REDIS_HOST: AgDfE4xJlP1XKrh0nHdUvYiGLl... # Replace with actual sealed secret
  template:
    metadata:
      name: db-credentials
      namespace: NAMESPACE_PLACEHOLDER
    type: Opaque
EOT
  filename = "${path.module}/templates/db-credentials-template.yaml"
}

# Create TLS certificates template
resource "local_file" "tls_certificates_template" {
  content  = <<-EOT
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: tls-certificates
  namespace: NAMESPACE_PLACEHOLDER
spec:
  encryptedData:
    tls.crt: AgBy8hgMjOULBXBnMVBmJEGkWIQKVD... # Replace with actual sealed secret
    tls.key: AgBy8hh7mJVHQHyUSGdl3M5RY2R... # Replace with actual sealed secret
  template:
    metadata:
      name: tls-certificates
      namespace: NAMESPACE_PLACEHOLDER
    type: kubernetes.io/tls
EOT
  filename = "${path.module}/templates/tls-certificates-template.yaml"
}
