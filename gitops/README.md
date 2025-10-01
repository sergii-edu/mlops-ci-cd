# gitops/ (моно-репозиторій)

У цьому репозиторії ми поєднали IaC (Terraform) і GitOps (ArgoCD) в одному місці.
ArgoCD ApplicationSet у `terraform/argocd/main.tf` сканує лише підпапки тут:
- `gitops/namespaces/*`
- `gitops/apps/*`
і створює `Application` ресурси автоматично.
