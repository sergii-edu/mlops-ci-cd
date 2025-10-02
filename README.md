# GOIT ArgoCD Project (Mono-repo)

## 📖 Опис
Mono-repo підхід: в одному репозиторії міститься як Terraform (EKS + ArgoCD), так і GitOps-конфіги (Application, Namespaces).

---

## 🚀 Як запустити

### 1. Підняти EKS-кластер
```bash
cd terraform/eks-cluster
terraform init
terraform apply
```

### 2. Розгорнути ArgoCD через Terraform
```bash
cd terraform/argocd
terraform init
terraform apply -var="cluster_name=mlops-eks-cluster"
```

### 3. Перевірити pod-и ArgoCD
```bash
kubectl get pods -n infra-tools
```

### 4. Увійти в ArgoCD UI
Отримати пароль:
```bash
kubectl -n infra-tools get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
Port-forward:
```bash
kubectl port-forward svc/argocd-server -n infra-tools 8080:80
```
Відкрити [http://localhost:8080](http://localhost:8080), логін `admin`, пароль – див. вище.

### 5. Перевірити деплой MLflow
```bash
kubectl get applications -n infra-tools
kubectl get pods -n application
```

### 6. Відкрити MLflow сервіс
```bash
kubectl -n application port-forward deploy/mlflow 5000:5000
```
Відкрити [http://localhost:5000](http://localhost:5000)

### 7. Видалення інфраструктури
```bash
cd terraform/argocd
terraform destroy
cd ../eks-cluster
terraform destroy
```

---

## 📂 Структура проєкту
```
terraform/
 ├── eks-cluster/              # Terraform для створення EKS
 └── argocd/                   # Terraform для ArgoCD
     ├── main.tf
     ├── variables.tf
     ├── providers.tf
     ├── outputs.tf
     ├── backend.tf
     └── values/
         └── argocd-values.yaml
goit-argo/
 ├── application.yaml          # ArgoCD Application для MLflow
 └── namespaces/
     ├── application/ns.yaml
     └── infra-tools/ns.yaml
README.md
```