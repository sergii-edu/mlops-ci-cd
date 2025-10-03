output "argocd_namespace" {
  value = var.argocd_namespace
}

output "argocd_server_service" {
  value = "svc/argocd-server"
}

output "argocd_port_forward_hint" {
  value = "kubectl port-forward svc/argocd-server -n ${var.argocd_namespace} 8080:80"
}
