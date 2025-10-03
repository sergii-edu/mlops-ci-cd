#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os, time, shutil, json
from pathlib import Path
from typing import Tuple, Dict
from dotenv import load_dotenv
load_dotenv()
import joblib
import mlflow
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, log_loss
from sklearn.linear_model import SGDClassifier
from prometheus_client import CollectorRegistry, Gauge, push_to_gateway

TRACKING_URI = os.getenv("MLFLOW_TRACKING_URI", "http://localhost:5000")
EXPERIMENT_NAME = os.getenv("MLFLOW_EXPERIMENT", "Iris Classification (SGD)")
ARTIFACT_SUBPATH = "model"
PUSHGATEWAY_URL = os.getenv("PUSHGATEWAY_URL", "http://pushgateway.monitoring.svc.cluster.local:9091")
PROM_JOB_NAME = os.getenv("PUSHGATEWAY_JOB", "mlflow_iris_runs")

BEST_DIR = Path(__file__).resolve().parent.parent / "best_model"
BEST_DIR.mkdir(parents=True, exist_ok=True)

def send_metrics_to_pushgateway(metrics: Dict[str, float], labels: Dict[str, str]) -> None:
    registry = CollectorRegistry()
    g_acc = Gauge("mlflow_accuracy", "Validation accuracy from MLflow run", labelnames=tuple(labels.keys()), registry=registry)
    g_loss = Gauge("mlflow_loss", "Validation log loss from MLflow run", labelnames=tuple(labels.keys()), registry=registry)
    g_acc.labels(**labels).set(metrics["accuracy"])
    g_loss.labels(**labels).set(metrics["loss"])
    push_to_gateway(PUSHGATEWAY_URL, job=PROM_JOB_NAME, registry=registry)

def run_once(lr: float, epochs: int) -> Tuple[str, float, float, str]:
    X, y = load_iris(return_X_y=True)
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)
    mlflow.set_tracking_uri(TRACKING_URI)
    experiment = mlflow.get_experiment_by_name(EXPERIMENT_NAME)
    if experiment is None:
        experiment_id = mlflow.create_experiment(EXPERIMENT_NAME)
    else:
        experiment_id = experiment.experiment_id
    with mlflow.start_run(experiment_id=experiment_id) as active_run:
        run_id = active_run.info.run_id
        mlflow.log_param("learning_rate", lr)
        mlflow.log_param("epochs", epochs)
        model = SGDClassifier(loss="log_loss", max_iter=epochs, learning_rate="constant", eta0=lr, random_state=42)
        model.fit(X_train, y_train)
        y_pred = model.predict(X_test)
        y_proba = model.predict_proba(X_test)
        acc = accuracy_score(y_test, y_pred)
        loss = log_loss(y_test, y_proba)
        mlflow.log_metric("accuracy", acc)
        mlflow.log_metric("loss", loss)
        local_model_dir = Path("artifacts_model"); local_model_dir.mkdir(exist_ok=True)
        model_path = local_model_dir / "model.joblib"
        joblib.dump(model, model_path)
        mlflow.log_artifact(str(model_path), ARTIFACT_SUBPATH)
        labels = {"run_id": run_id, "lr": str(lr), "epochs": str(epochs)}
        send_metrics_to_pushgateway({"accuracy": acc, "loss": loss}, labels)
        return run_id, acc, loss, str(local_model_dir)

def main():
    learning_rates = [0.001, 0.01, 0.05]
    epoch_options = [200, 400, 800]
    best = {"acc": -1.0, "run_id": None, "model_dir": None, "lr": None, "epochs": None}
    for lr in learning_rates:
        for epochs in epoch_options:
            run_id, acc, loss, model_dir = run_once(lr, epochs)
            print(f"[run_id={run_id}] lr={lr} epochs={epochs} -> acc={acc:.4f}, loss={loss:.4f}")
            if acc > best["acc"]:
                best.update({"acc": acc, "run_id": run_id, "model_dir": model_dir, "lr": lr, "epochs": epochs})
            time.sleep(0.25)
    src = Path(best["model_dir"]) / "model.joblib"
    dst = BEST_DIR / f"best_model_lr{best['lr']}_e{best['epochs']}.joblib"
    shutil.copy2(src, dst)
    meta = {"best_run_id": best["run_id"], "best_accuracy": best["acc"], "best_lr": best["lr"], "best_epochs": best["epochs"], "artifact": dst.name}
    (BEST_DIR / "best_model_meta.json").write_text(json.dumps(meta, indent=2, ensure_ascii=False))
    print("Best model saved to:", str(dst))
    print(json.dumps(meta, indent=2, ensure_ascii=False))

if __name__ == "__main__":
    main()
