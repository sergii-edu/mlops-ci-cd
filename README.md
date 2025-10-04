# 🚀 MLOps Lesson 8–9 — MLflow + Grafana + ArgoCD  

Цей проєкт реалізує повний цикл **трекінгу ML-експериментів** із логуванням у **MLflow**, візуалізацією у **Grafana** та автоматичним розгортанням інфраструктури через **ArgoCD**.  

- Після тестування обов’язково виконайте:  

```bash
terraform destroy
```

---

## 📁 Структура проєкту

```
mlops-ci-cd-lesson-8-9/
├── experiments/
│   ├── requirements.txt       # Python-залежності
│   └── train_and_push.py      # Скрипт тренування і пушу метрик
├── goit-argo/
│   ├── application.yaml       # Основний Application для ArgoCD
│   ├── apps/
│   │   ├── minio.yaml
│   │   ├── mlflow.yaml
│   │   ├── postgres.yaml
│   │   └── pushgateway.yaml
│   └── namespaces/
│       ├── application/
│       │   ├── ns.yaml
│       │   └── nginx.yaml
│       ├── infra-tools/ns.yaml
│       └── monitoring/ns.yaml
├── terraform/
│   ├── eks-cluster/           # Terraform для EKS
│   └── argocd/                # Terraform для ArgoCD
│       ├── main.tf
│       ├── variables.tf
│       ├── providers.tf
│       └── values/argocd-values.yaml
└── README.md
```

---

## ⚙️ Кроки виконання

### 1. Розгортання MLflow через ArgoCD
```bash
kubectl apply -f goit-argo/application.yaml
```

- **MinIO** з bucket `mlflow-artifacts`.  
- **Postgres** з БД `mlflow`.  
- **MLflow Tracking Server** (порт `5000`).  

Перевірка доступності:
```bash
kubectl port-forward svc/mlflow 5000:5000 -n application
```
Тепер UI доступний за адресою:  
👉 [http://localhost:5000](http://localhost:5000)

---

### 2. Розгортання PushGateway через ArgoCD
```bash
kubectl apply -f goit-argo/apps/pushgateway.yaml
```

Доступність:
```bash
kubectl port-forward svc/pushgateway 9091:9091 -n monitoring
```
👉 [http://localhost:9091](http://localhost:9091)

---

### 3. Запуск Python-скрипту
Перейдіть у директорію `experiments/` та встановіть залежності:

```bash
pip install -r requirements.txt
```

Запуск:
```bash
python train_and_push.py
```

Скрипт:  
- Завантажує датасет **Iris**.  
- Виконує тренування з різними параметрами.  
- Логує все у **MLflow**.  
- Пушить `accuracy` та `loss` у **PushGateway**.  
- Копіює найкращу модель у `best_model/`.  

---

### 4. Перегляд метрик у Grafana
1. Відкрийте Grafana.  
2. Перейдіть у **Explore → Prometheus**.  
3. Запустіть запити:
   - `mlflow_accuracy`
   - `mlflow_loss`  

Можна побудувати графіки або табличний вигляд.  

---

## 📸 Скриншоти
- MLflow UI — історія запусків і метрики.  
- Grafana Explore — графіки accuracy/loss.  

*(Додайте свої скріни з LMS або локального кластера)*  
