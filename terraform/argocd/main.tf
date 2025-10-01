# Create namespace for ArgoCD
resource "kubernetes_namespace" "argo" {
  metadata {
    name = var.argocd_namespace
  }
}

# Install ArgoCD via Helm
resource "helm_release" "argo" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argo.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version

  recreate_pods = true
  replace       = true

  values = [file("${path.module}/values/argocd-values.yaml")]
}

# ApplicationSet reads directories ONLY under gitops/
resource "kubernetes_manifest" "gitops_appset" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "ApplicationSet"
    metadata = {
      name      = "gitops-apps"
      namespace = var.argocd_namespace
    }
    spec = {
      generators = [{
        git = {
          repoURL    = var.app_repo_url
          revision   = var.app_repo_branch
          directories = [
            { path = "gitops/namespaces/*" },
            { path = "gitops/apps/*" }
          ]
        }
      }]
      template = {
        metadata = {
          name      = "{{path.basename}}"
          namespace = var.argocd_namespace
        }
        spec = {
          project = "default"
          source = {
            repoURL        = var.app_repo_url
            targetRevision = var.app_repo_branch
            path           = "{{path}}"
            directory = {
              recurse = true
            }
          }
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = "application"
          }
          syncPolicy = {
            automated   = { prune = true, selfHeal = true }
            syncOptions = ["CreateNamespace=true"]
          }
          revisionHistoryLimit = 2
        }
      }
    }
  }
  depends_on = [helm_release.argo]
}
