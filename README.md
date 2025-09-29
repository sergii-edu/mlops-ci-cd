# EKS + VPC Terraform (eu-west-1)

Простий проєкт, що створює VPC (публічні/приватні підмережі, NAT/IGW) та кластер **Amazon EKS** з двома node groups: CPU (активна) і GPU (за замовчуванням вимкнена).

## Вимоги

- **AWS CLI** та налаштований профіль (наприклад, `mlops`)
- **Terraform** ≥ 1.5
- Доступ до AWS з правами створення S3, VPC, EKS, IAM, KMS

## Архітектура

- VPC `10.0.0.0/16` у `eu-west-1` з 3 AZ (`a/b/c`)
- 3 public + 3 private subnets
- 1 NAT Gateway (економ-вариант)
- EKS кластер `mlops-eks` (v1.31)
- Managed Node Groups:
  - `cpu-nodes`: `t3.medium`, desired=2, min=1, max=3
  - `gpu-nodes`: `g4dn.xlarge`, desired=0 (вимкнено)
- KMS key для шифрування секретів кластера

## Структура

```
eks-vpc-cluster/
├── main.tf
├── variables.tf
├── outputs.tf
├── backend.tf          # тільки в корені! (модульні backend.tf ігноруються)
├── eks/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── backend.tf      # попередження: ігнорується як child module
├── vpc/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── backend.tf      # попередження: ігнорується як child module
└── README.md
```

## Підготовка S3 backend

1) Створи bucket у **eu-west-1** (приклад):
```bash
aws s3api create-bucket   --bucket mlops-terraform-states-12345   --region eu-west-1   --create-bucket-configuration LocationConstraint=eu-west-1   --profile mlops
```

2) У `backend.tf` (root) вкажи:
```hcl
terraform {
  backend "s3" {
    bucket  = "mlops-terraform-states-12345"
    key     = "eks/terraform.tfstate"
    region  = "eu-west-1"
    profile = "mlops"
  }
}
```

> Важливо: region bucket’а та `region` у backend мають збігатися.

## Швидкий старт

```bash
# (1) Перевір профіль
aws sts get-caller-identity --profile mlops

# (2) Ініціалізація
terraform init -reconfigure

# (3) Перевір план
terraform plan -var="aws_profile=mlops" -var="aws_region=eu-west-1"

# (4) Застосувати
terraform apply -var="aws_profile=mlops" -var="aws_region=eu-west-1"
# або збережений план:
# terraform plan -out=tfplan -var="aws_profile=mlops" -var="aws_region=eu-west-1"
# terraform apply tfplan
```

Після `apply` — підключення до кластера:
```bash
aws eks --region eu-west-1 --profile mlops update-kubeconfig --name mlops-eks
kubectl get nodes -o wide
```

## Змінні (головні)

| Змінна | Тип | Приклад (дефолт) | Опис |
|---|---|---|---|
| `aws_region` | string | `eu-west-1` | Регіон AWS |
| `aws_profile` | string | `mlops` | Профіль AWS CLI |
| `vpc_name` | string | `mlops-vpc` | Ім’я VPC |
| `vpc_cidr` | string | `10.0.0.0/16` | CIDR VPC |
| `azs` | list(string) | `["eu-west-1a","eu-west-1b","eu-west-1c"]` | AZ |
| `public_subnets` | list(string) | `["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]` | Публічні підмережі |
| `private_subnets` | list(string) | `["10.0.11.0/24","10.0.12.0/24","10.0.13.0/24"]` | Приватні підмережі |
| `enable_nat_gateway` | bool | `true` | Увімкнути NAT |
| `single_nat_gateway` | bool | `true` | Один NAT на VPC |
| `cluster_name` | string | `mlops-eks` | Ім’я EKS |
| `cluster_version` | string | `1.31` | Версія EKS |
| `cpu_instance_types` | list(string) | `["t3.medium"]` | Типи CPU нод |
| `cpu_node_desired` | number | `2` | Бажана кількість CPU нод |
| `cpu_node_min` | number | `1` | Мін. CPU нод |
| `cpu_node_max` | number | `3` | Макс. CPU нод |
| `enable_gpu_node_group` | bool | `false` | Вмикає GPU групу |
| `gpu_instance_types` | list(string) | `["g4dn.xlarge"]` | Типи GPU нод |
| `gpu_node_desired` | number | `0` | Бажана кількість GPU нод |
| `gpu_node_min` | number | `0` | Мін. GPU нод |
| `gpu_node_max` | number | `1` | Макс. GPU нод |

Можеш створити `terraform.tfvars`:
```hcl
aws_profile = "mlops"
aws_region  = "eu-west-1"
```

## Увімкнути GPU ноди (за потреби)

```bash
terraform apply   -var="aws_profile=mlops" -var="aws_region=eu-west-1"   -var="enable_gpu_node_group=true"   -var="gpu_node_desired=1"
```

## Знищити ресурси

```bash
terraform destroy -var="aws_profile=mlops" -var="aws_region=eu-west-1"
```

## Попередження та вартість

- **NAT Gateway** — платний щогодинно + трафік. У конфігурації використовується **один** NAT.
- GPU група з `desired=0` — витрат не створює, поки не ввімкнеш.
- Backend блоки у `eks/backend.tf` і `vpc/backend.tf` ігноруються як **child modules** — це нормальні попередження.

## Траблшутінг

**301 / bucket region mismatch**  
> `requested bucket from "us-east-1", actual location "eu-west-1"`  
Переконайся, що `backend.tf` в корені має `region = "eu-west-1"` і повтори:
```bash
terraform init -reconfigure
```

**403 / state lock AccessDenied**  
Немає прав на S3 bucket або вказаний інший bucket/key. Перевір профіль/політики та значення у `backend.tf`.

**No stored state for remote_state (EKS читає VPC state)**  
Якщо модуль EKS читає `data terraform_remote_state` VPC — переконайся, що VPC вже застосований і шляхи `bucket/key/region/profile` збігаються. (У поточному варіанті VPC і EKS створюються разом, без окремого remote_state між модулями.)

**Insufficient capacity для `g4dn.xlarge`**  
Трапляється інколи. Залиш `desired=0` або спробуй інші типи (`g5.*`/`p3.*`) чи іншу AZ.
