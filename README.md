# Lesson 7 — Mono‑repo: Terraform (ArgoCD) + GitOps (MLflow)

У цьому моно‑репозиторії одночасно зберігаються:
- `terraform/argocd` — Terraform, який встановлює ArgoCD (helm_release) у `infra-tools`, вмикає ApplicationSet.
- `gitops/` — папки, які читає ArgoCD ApplicationSet і з яких створюються `Application` (наприклад, MLflow).

> У реальних проєктах IaC і GitOps зазвичай — окремі репозиторії. Тут вони поєднані **для зручності здачі ДЗ**.

---

## Кроки запуску

### 0) Підготуйте URL цього ж репозиторію
- Запуште цей код на GitHub у репозиторій `<this-repo>`.
- Створіть гілку **lesson-7** (вимога LMS).

### 1) Оновіть змінні Terraform
У файлі `terraform/argocd/variables.tf` змініть:
- `app_repo_url` → `https://github.com/<your-account>/<this-repo>.git`
- `app_repo_branch` → `lesson-7` (або іншу гілку, яку будете пушити)

Також перевірте:
- `aws_profile`, `aws_region`
- `eks_state_bucket`, `eks_state_key`, `eks_state_region` — щоб вказували на ваш **remote state EKS**

### 2) Розгорніть ArgoCD через Terraform
```bash
cd terraform/argocd
terraform init -reconfigure
terraform plan
terraform apply
```
Перевірте pod-и:
```bash
kubectl get pods -n infra-tools
```

### 3) Вхід у UI ArgoCD
```bash
# пароль адміністратора
kubectl -n infra-tools get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

# локальний доступ
kubectl port-forward svc/argocd-server -n infra-tools 8080:80
```
Відкрийте `http://localhost:8080` (login: `admin`, password: з команди вище).

### 4) Перевірте ApplicationSet
```bash
kubectl -n infra-tools get deploy argocd-applicationset-controller
kubectl -n infra-tools get applicationsets.argoproj.io
```

### 5) Переконайтеся, що створився застосунок MLflow
ApplicationSet сканує **цей самий репозиторій** за шляхами:
- `gitops/namespaces/*`
- `gitops/apps/*`

Має з’явитися `Application` з ім’ям **mlflow** (із `gitops/apps/mlflow/application.yaml`).

CLI:
```bash
kubectl -n infra-tools get applications.argoproj.io
```

UI: перевірте статус синхронізації; має створити ресурси в namespace `application`.

### 6) Перевірка подів і доступу
```bash
kubectl get pods -n application
kubectl -n application get deploy,svc
# локальний доступ (ім'я деплойменту див. у виводі get deploy)
kubectl -n application port-forward deploy/<mlflow-deploy-name> 5000:5000
# тепер відкрийте http://localhost:5000
```

---

## Знищення ресурсів (обовʼязково після перевірки)
```bash
cd terraform/argocd
terraform destroy
```

## Примітки
- `argocd-values.yaml` містить ClusterIP, extraArgs, RBAC, timeouts і `applicationSet.enabled: true`.
- У `gitops/apps/mlflow/application.yaml` зафіксуйте конкретну версію `targetRevision` під ваш кластер/Helm.
- Якщо потрібно, можете додати інші апки під `gitops/apps/<app-name>/application.yaml` — ApplicationSet підхопить їх автоматично.

Успіхів! 🚀
