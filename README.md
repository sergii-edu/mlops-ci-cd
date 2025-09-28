# lesson-3 — Контейнеризація ML-моделей (TorchScript + Docker)

## Швидкий старт (локально)
```bash
bash install_dev_tools.sh
python3 export_model.py
python3 inference.py path/to/image.jpg
```

## Docker
```bash
docker build -t ml-fat -f Dockerfile.fat .
docker run --rm -v $PWD:/app ml-fat path/to/image.jpg

docker build -t ml-slim -f Dockerfile.slim .
docker run --rm -v $PWD:/app ml-slim path/to/image.jpg
```
> У slim-runtime немає torchvision — класи збережені у `labels.json`.

## Структура
```
lesson-3/
├── inference.py
├── export_model.py
├── model.pt
├── Dockerfile.fat
├── Dockerfile.slim
├── install_dev_tools.sh
├── comparison.txt
└── README.md
```