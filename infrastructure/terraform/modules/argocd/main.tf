resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    templatefile("${path.module}/templates/argocd-values.yaml", {
      admin_password_bcrypt = var.argocd_admin_password_bcrypt
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}

# Create ApplicationSet for managing applications
resource "helm_release" "applicationset" {
  name       = "applicationset"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-applicationset"
  version    = var.applicationset_chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  depends_on = [helm_release.argocd]
}

# Register Git repositories
resource "kubernetes_manifest" "git_repositories" {
  for_each = { for repo in var.repos : repo.name => repo }

  manifest = {
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name      = "repo-${each.value.name}"
      namespace = kubernetes_namespace.argocd.metadata[0].name
      labels = {
        "argocd.argoproj.io/secret-type" = "repository"
      }
    }
    data = {
      type     = "git"
      url      = each.value.url
      username = var.git_username
      password = var.git_password
    }
  }

  depends_on = [helm_release.argocd]
}

# Create Application resources for each repo/path combination
resource "kubernetes_manifest" "applications" {
  for_each = { for repo in var.repos : "${repo.name}-${repo.namespace}" => repo }

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "app-${each.value.name}-${each.value.namespace}"
      namespace = kubernetes_namespace.argocd.metadata[0].name
    }
    spec = {
      project = "default"
      source = {
        repoURL        = each.value.url
        targetRevision = "HEAD"
        path           = each.value.path
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = each.value.namespace
      }
      syncPolicy = {
        automated = {
          prune     = true
          selfHeal  = true
          allowEmpty = false
        }
        retry = {
          limit   = 5
          backoff = {
            duration    = "5s"
            factor      = 2
            maxDuration = "3m"
          }
        }
        syncOptions = [
          "CreateNamespace=true",
          "PrunePropagationPolicy=foreground",
          "PruneLast=true"
        ]
      }
    }
  }

  depends_on = [kubernetes_manifest.git_repositories]
}
